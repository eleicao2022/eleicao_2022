const fs = require("fs");
const es = require("event-stream");

const regExNome = /\[[A-Z]{2,} [A-Z ]{2,}\]/g;

async function main() {
    const basePath = __dirname + "/../scripts/logs/turno=2";
    const files = fs.readdirSync(basePath).filter((f) => f.endsWith(".dat"));

    for (const file of files) {
        let lineNumber = 0;
        let currentUE = null;
        let currentTurno = null;
        let canLog = false;

        const urnas = {};
        const estado = file.split(".")[0].slice(-2);

        function processLine(line) {
            if (line.includes(" erro") && regExNome.test(line)) {
                const s = [
                    line.trim(),
                    " -- ",
                    "UF: " + estado,
                    " Mun.: " + currentUE.municipio,
                    " Zona: " + currentUE.zona,
                    " Secao: " + currentUE.secao,
                    " Urna: " + currentUE.modelo,
                ].join("");
                console.log(s);
            }

            const info = line.split("\t");

            const logType = info[3];
            const logMessage = info[4];

            if (logType == "LOGD") {
                if (logMessage.includes("Urna ligada em")) {
                    canLog = false;
                    isOficial = false;
                }
            } else if (logType == "GAP") {
                if (logMessage.includes("Modelo de Urna")) {
                    const un = logMessage.split(":")[1].trim();

                    currentUE = {
                        id: null,
                        modelo: un,
                        total_votos: 0,
                        turno: currentTurno,
                        estado: estado,
                        municipio: null,
                        zona: null,
                        secao: null,
                    };
                } else if (logMessage.includes("Fase da UE")) {
                    const fase = logMessage.split(":")[1].trim();
                    if (fase == "Oficial") {
                        canLog = true;
                    }
                } else if (logMessage.includes("Turno da UE")) {
                    const turno = logMessage.split(":")[1].trim();
                    currentTurno = parseInt(turno, 10);
                } else if (logMessage.includes("Município")) {
                    const val = logMessage.split(":")[1].trim();
                    currentUE.municipio = parseInt(val, 10);
                } else if (logMessage.includes("Zona Eleitoral")) {
                    const val = logMessage.split(":")[1].trim();
                    currentUE.zona = parseInt(val, 10);
                } else if (logMessage.includes("Seção Eleitoral")) {
                    const val = logMessage.split(":")[1].trim();
                    currentUE.secao = parseInt(val, 10);

                    const urnaId = [
                        currentUE.turno,
                        currentUE.municipio,
                        currentUE.zona,
                        currentUE.secao,
                    ].join("_");

                    if (urnas[urnaId]) {
                        currentUE = urnas[urnaId];
                    } else {
                        currentUE.id = urnaId;
                        urnas[urnaId] = { ...currentUE };
                    }
                }
            } else if (logType == "VOTA" && canLog) {
                if (logMessage.includes("[Presidente]")) {
                    urnas[currentUE.id].total_votos++;
                }
            }
        }

        await new Promise(function (ok, nok) {
            fs.createReadStream(basePath + "/" + file, "latin1")
                .pipe(es.split())
                .pipe(
                    es
                        .mapSync((line) => {
                            lineNumber++;

                            try {
                                processLine(line);
                            } catch (e) {
                                console.log(
                                    "ERROR: Log - Line number:",
                                    lineNumber,
                                    "\n\n"
                                );
                                nok(e);
                            }
                        })
                        .on("error", (err) => {
                            console.log("Error while reading file.", err);
                        })
                        .on("end", () => {
                            ok();
                        })
                );
        });
    }
}

main();
