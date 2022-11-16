import os
import asn1tools
from pathlib import Path


def get_modelo_urna(codigo):
    # https://dados.gov.br/dataset/correspondencia-entre-numero-interno-e-modelo-da-urna-1/
    urnas = {
        'UE2009': [999500, 1220500],
        'UE2010': [1220501, 1345500],
        'UE2011': [1368501, 1370500, 1600000, 1650000],
        'UE2013': [1650001, 1701000],
        'UE2015': [1750000, 1950000],
        'UE2020': [2000000, 2250000],
    }
    for key, value in urnas.items():
        for i in range(0, len(value), 2):
            if codigo >= value[i] and codigo <= value[i + 1]:
                return key
    return 'unknown'


asn1 = asn1tools.compile_files("./bu.asn1", codec="ber")
def processa_bu(bu_path: Path):
    with open(bu_path, "rb") as file:
        envelope_encoded = bytearray(file.read())
    envelope_decoded = asn1.decode("EntidadeEnvelopeGenerico", envelope_encoded)
    bu_encoded = envelope_decoded["conteudo"]
    bu_decoded = asn1.decode("EntidadeBoletimUrna", bu_encoded)

    if bu_decoded["fase"] == "oficial":
        votacao = [
                [
                    [
                        [{
                            "cargo": tot["codigoCargo"][1],
                            "tipo_voto": a["tipoVoto"],
                            "total_votos": a["quantidadeVotos"],
                            "codigo": a["identificacaoVotavel"]["codigo"] if "identificacaoVotavel" in a else 0,
                            "partido": a["identificacaoVotavel"]["partido"] if "identificacaoVotavel" in a else 0,
                        } for a in tot["votosVotaveis"]
                    ] for tot in vot["totaisVotosCargo"]
                ] for vot in res["resultadosVotacao"]

            ] for res in bu_decoded["resultadosVotacaoPorEleicao"]
        ][0][0][0]


        obj = {
            "fase": bu_decoded["fase"],
            "versao": bu_decoded["urna"]["versaoVotacao"],
            "id_eleicao": [res["idEleicao"] for res in bu_decoded["resultadosVotacaoPorEleicao"]][0],
            "municipio": bu_decoded["identificacaoSecao"]["municipioZona"]["municipio"],
            "zona": bu_decoded["identificacaoSecao"]["municipioZona"]["zona"],
            "local": bu_decoded["identificacaoSecao"]["local"],
            "secao": bu_decoded["identificacaoSecao"]["secao"],
            "quantidade_eleitores": [res["qtdEleitoresAptos"] for res in bu_decoded["resultadosVotacaoPorEleicao"]][0],
            "modelo_urna": get_modelo_urna(bu_decoded["urna"]["correspondenciaResultado"]["carga"]["numeroInternoUrna"]),
            "total_votos": sum(v["total_votos"] for v in votacao),
            "votacao": votacao,
        }
        obj["abstencao"] = obj["quantidade_eleitores"] - obj["total_votos"]

        return obj

    return None

def writeSQL(votos):
    if len(votos) == 0:
        return

    SQL = "INSERT INTO voto (secao_id, cargo, candidato, partido, total_votos, modelo_urna) SELECT * FROM (" + " UNION ALL ".join(votos) + ") AS X;\n"
    with open("./../sql/votos.sql", "a") as file:
        file.write(SQL)

def writeSQLSecao(secoes):
    if len(secoes) == 0:
        return
    SQL = "INSERT INTO secao (id, estado, municipio, zona, secao, turno, modelo_urna, quantidade_eleitores, abstencao, total_votos) SELECT * FROM (" + " UNION ALL ".join(secoes) + ") AS X;\n"
    with open("./../sql/secoes.sql", "a") as file:
        file.write(SQL)

if __name__ == "__main__":
    rootdir = str(Path(__file__).parent.resolve()) + '/../scripts/logs'
    folder = Path(rootdir)

    votos = []
    secoes = []
    idx = 0
    idxSecao = 0
    for file in folder.glob('**/*.bu'):
        folder_name = str(file).split(os.sep)[-2]
        estado = folder_name[-2:]
        turno = folder_name[-5:-4]

        bu = processa_bu(file)

        if bu is not None:
            idxSecao += 1
            idSecao = "_".join([turno, str(bu["municipio"]), str(bu["zona"]), str(bu["secao"])])

            if len(secoes) == 0:
                secoes.append(
                    "SELECT " +
                    ",".join([
                        "'" + idSecao + "' AS id",
                        "'" + estado + "' AS estado",
                        str(bu["municipio"]) + ' AS municipio',
                        str(bu["zona"]) + ' AS zona',
                        str(bu["secao"]) + ' AS secao',
                        turno + ' AS turno',
                        "'" + bu["modelo_urna"] + "' AS modelo_urna",
                        str(bu["quantidade_eleitores"]) + ' AS quantidade_eleitores',
                        str(bu["abstencao"]) + ' AS abstencao',
                        str(bu["total_votos"]) + ' AS total_votos',
                    ])
                )
            else:
                secoes.append(
                    "SELECT " +
                        ",".join([
                            "'" + idSecao + "'",
                            "'" + estado + "'",
                            str(bu["municipio"]),
                            str(bu["zona"]),
                            str(bu["secao"]),
                            turno,
                            "'" + bu["modelo_urna"] + "'",
                            str(bu["quantidade_eleitores"]),
                            str(bu["abstencao"]),
                            str(bu["total_votos"]),
                        ])
                )

            if idxSecao % 500 == 0:
                writeSQLSecao(secoes)
                secoes = []

            for voto in bu["votacao"]:
                idx += 1

                if len(votos) == 0:
                    votos.append(
                        "SELECT " +
                            ",".join([
                                "'" + idSecao + "' AS secao_id",
                                "'" + voto["cargo"] + "' AS cargo",
                                str(voto["codigo"]) + " AS candidato",
                                str(voto["partido"]) + " AS partido",
                                str(voto["total_votos"]) + " AS total_votos",
                                "'" + bu["modelo_urna"] + "' AS modelo_urna",
                            ])
                    )
                else:
                    votos.append(
                        "SELECT " +
                            ",".join([
                                "'" + idSecao + "'",
                                "'" + voto["cargo"] + "'",
                                str(voto["codigo"]),
                                str(voto["partido"]),
                                str(voto["total_votos"]),
                                "'" + bu["modelo_urna"] + "'",
                            ])
                    )

                if idx % 500 == 0:
                    writeSQL(votos)
                    votos = []

    writeSQL(votos)
    writeSQLSecao(secoes)
