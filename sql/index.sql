------------------ urna ----------------------------
CREATE INDEX IF NOT EXISTS IX_urna_modelo ON urna_logs (
	modelo
);

CREATE INDEX IF NOT EXISTS IX_urna_logs_turno ON urna_logs (
	turno
);

CREATE INDEX IF NOT EXISTS IX_urna_logs_estado ON urna_logs (
	estado
);

CREATE INDEX IF NOT EXISTS IX_urna_logs_municipio ON urna_logs (
	municipio
);

CREATE INDEX IF NOT EXISTS IX_urna_logs_zona ON urna_logs (
	zona
);

CREATE INDEX IF NOT EXISTS IX_urna_logs_secao ON urna_logs (
	secao
);


------------------ secao ----------------------------
CREATE INDEX IF NOT EXISTS IX_secao_turno ON secao (
	turno
);

CREATE INDEX IF NOT EXISTS IX_secao_estado ON secao (
	estado
);

CREATE INDEX IF NOT EXISTS IX_secao_municipio ON secao (
	municipio
);

CREATE INDEX IF NOT EXISTS IX_secao_zona ON secao (
	zona
);

CREATE INDEX IF NOT EXISTS IX_secao_secao ON secao (
	secao
);


------------------ voto ----------------------------

CREATE INDEX IF NOT EXISTS IX_voto_secao_id ON voto (
	secao_id
);

CREATE INDEX IF NOT EXISTS IX_voto_cargo ON voto (
	cargo
);

CREATE INDEX IF NOT EXISTS IX_voto_candidato ON voto (
	candidato
);

CREATE INDEX IF NOT EXISTS IX_voto_candidato ON voto (
	modelo_urna
);