-- votos em urnas < 2020
select
	v.candidato,
	s.estado,
	sum(v.total_votos) * 1.0 / (select sum(a.total_votos) from voto a inner join secao b ON b.id = a.secao_id where b.estado = s.estado AND a.candidato != 0 AND a.cargo = "presidente" AND a.modelo_urna != 'UE2020') * 1.0 * 100.0
from voto v
inner join secao s ON s.id = v.secao_id
where v.candidato != 0 AND v.cargo = "presidente" AND v.modelo_urna != 'UE2020'
GROUP BY s.estado, v.candidato;


-- votos em urnas 2020
select
	v.candidato,
	s.estado,
	sum(v.total_votos) * 1.0 / (select sum(a.total_votos) from voto a inner join secao b ON b.id = a.secao_id where b.estado = s.estado AND a.candidato != 0 AND a.cargo = "presidente" AND a.modelo_urna == 'UE2020') * 1.0 * 100.0
from voto v
inner join secao s ON s.id = v.secao_id
where v.candidato != 0 AND v.cargo = "presidente" AND v.modelo_urna == 'UE2020'
GROUP BY s.estado, v.candidato;


-- representaçao de urnas por estado
select
	count(v.modelo_urna),
	count(v.modelo_urna) * 1.0 / (select count(a.modelo_urna) from voto a inner join secao b ON b.id = a.secao_id where a.cargo = "presidente") * 1.0 * 100.0
from voto v
inner join secao s ON s.id = v.secao_id
where v.cargo = "presidente" AND v.modelo_urna == 'UE2020';
