-- ==============================================
-- Parte 1: As 8 Visões com 4 Operadores
-- ==============================================

-- Limpeza para evitar erros caso precise rodar mais de uma vez
DROP VIEW IF EXISTS vw_professores_metricas, vw_detalhe_cursos_view CASCADE;
DROP VIEW IF EXISTS vw_professores_turmas, vw_cursos_ativos, vw_planos_ensino_detalhe, vw_atividades_aula, vw_aulas_excelencia, vw_resumo_ucs, vw_capacidades_tecnicas, vw_professores_ativos CASCADE;

-- Visão 1
-- Operadores: COUNT (Agregação), >= e > (Relacional), AND (Lógico), IN (Especial)
CREATE OR REPLACE VIEW vw_professores_ativos AS
SELECT p.nome, COUNT(pp.id_plano_ensino) as total_planos
FROM professor p
JOIN plano_prof pp ON p.id_professor = pp.id_professor
JOIN plano_ensino pe ON pp.id_plano_ensino = pe.id_plano_ensino
WHERE pe.ano IN (2024, 2025) AND pe.semestre >= 1 
GROUP BY p.nome
HAVING COUNT(pp.id_plano_ensino) > 1;

-- Visão 2
-- Operadores: COUNT (Agregação), < e > (Relacional), OR (Lógico), LIKE (Especial)
CREATE OR REPLACE VIEW vw_capacidades_tecnicas AS
SELECT pa.descricao, COUNT(ac.id_capacidade) AS qtd_capacidades
FROM plano_aula pa
JOIN aula_capacidade ac ON pa.id_plano_aula = ac.id_plano_aula
JOIN capacidade c ON ac.id_capacidade = c.id_capacidade
WHERE (c.tipo LIKE '%Técnica%' OR c.tipo = 'Soft Skill') AND pa.avaliacao < 10.0
GROUP BY pa.descricao
HAVING COUNT(ac.id_capacidade) > 0;

-- Visão 3
-- Operadores: COUNT (Agregação), <= e > (Relacional), AND (Lógico), BETWEEN (Especial)
CREATE OR REPLACE VIEW vw_resumo_ucs AS
SELECT c.nome as curso, COUNT(uc.id_uc) as total_ucs
FROM curso c
JOIN unidade_curricular uc ON c.id_curso = uc.id_curso
WHERE uc.ano BETWEEN 2024 AND 2026 AND uc.semestre <= 2
GROUP BY c.nome
HAVING COUNT(uc.id_uc) > 0;

-- Visão 4
-- Operadores: AVG (Agregação), > (Relacional), AND (Lógico), EXISTS (Especial)
CREATE OR REPLACE VIEW vw_aulas_excelencia AS
SELECT pa.id_plano_aula, pa.descricao, AVG(pa.avaliacao) as media_nota
FROM plano_aula pa
WHERE pa.avaliacao > 8.0 AND EXISTS (
    SELECT 1 FROM aula_capacidade ac WHERE ac.id_plano_aula = pa.id_plano_aula
)
GROUP BY pa.id_plano_aula, pa.descricao
HAVING AVG(pa.avaliacao) > 8.5;

-- Visão 5
-- Operadores: MAX (Agregação), <> e >= (Relacional), AND (Lógico), IN (Especial)
CREATE OR REPLACE VIEW vw_atividades_aula AS
SELECT pa.descricao, MAX(pa.avaliacao) as nota_maxima
FROM plano_aula pa
JOIN plano_ativ pat ON pa.id_plano_aula = pat.id_plano_aula
JOIN atividade a ON pat.id_atividade = a.id_atividade
WHERE a.nome IN ('Prova Escrita', 'Projeto Prático') AND pa.avaliacao <> 0
GROUP BY pa.descricao
HAVING MAX(pa.avaliacao) >= 7.0;

-- Visão 6
-- Operadores: MIN (Agregação), = e > (Relacional), OR (Lógico), BETWEEN (Especial)
CREATE OR REPLACE VIEW vw_planos_ensino_detalhe AS
SELECT pe.cod_turma, MIN(pa.avaliacao) as menor_nota
FROM plano_ensino pe
JOIN plano_aula pa ON pe.id_plano_ensino = pa.id_plano_ensino
WHERE pe.ano BETWEEN 2024 AND 2025 OR pe.semestre = 1
GROUP BY pe.cod_turma
HAVING MIN(pa.avaliacao) > 5.0;

-- Visão 7
-- Operadores: SUM (Agregação), >= e > (Relacional), AND (Lógico), LIKE (Especial)
CREATE OR REPLACE VIEW vw_cursos_ativos AS
SELECT c.nome, SUM(pa.avaliacao) as soma_avaliacoes
FROM curso c
JOIN unidade_curricular uc ON c.id_curso = uc.id_curso
JOIN plano_ensino pe ON uc.id_uc = pe.id_uc
JOIN plano_aula pa ON pe.id_plano_ensino = pa.id_plano_ensino
WHERE c.nome LIKE '%Engenharia%' AND pa.avaliacao >= 6.0
GROUP BY c.nome
HAVING SUM(pa.avaliacao) > 5.0;

-- Visão 8
-- Operadores: COUNT (Agregação), != e > (Relacional), AND (Lógico), IN (Especial)
CREATE OR REPLACE VIEW vw_professores_turmas AS
SELECT p.nome, COUNT(pe.id_plano_ensino) as turmas_alocadas
FROM professor p
JOIN plano_prof pp ON p.id_professor = pp.id_professor
JOIN plano_ensino pe ON pp.id_plano_ensino = pe.id_plano_ensino
WHERE p.matricula IN ('MAT001', 'MAT002', 'MAT003') AND pe.semestre != 2
GROUP BY p.nome
HAVING COUNT(pe.id_plano_ensino) > 0;

-- ==================================================
-- Parte 2: As 2 Visões Híbridas (Tabela + Visão)
-- ==================================================

-- Visão 9: Mistura a Visão 3 com a Tabela 'curso'
CREATE OR REPLACE VIEW vw_detalhe_cursos_view AS
SELECT v.curso, v.total_ucs, c.objetivo
FROM vw_resumo_ucs v
JOIN curso c ON v.curso = c.nome;

-- Visão 10: Mistura a Visão 1 com a Tabela 'professor'
CREATE OR REPLACE VIEW vw_professores_metricas AS
SELECT v.nome, v.total_planos, p.matricula
FROM vw_professores_ativos v
JOIN professor p ON v.nome = p.nome;

-- ==================================================
-- Parte 3: As 10 Consultas Usando Múltiplas Visões
-- ==================================================

-- Consulta 1: Cruzando aulas de excelência com suas capacidades
SELECT vae.descricao, vae.media_nota, vct.qtd_capacidades
FROM vw_aulas_excelencia vae
JOIN vw_capacidades_tecnicas vct ON vae.descricao = vct.descricao;

-- Consulta 2: Cruzando as capacidades das aulas com a nota máxima da atividade
SELECT vct.descricao, vct.qtd_capacidades, vaa.nota_maxima
FROM vw_capacidades_tecnicas vct
JOIN vw_atividades_aula vaa ON vct.descricao = vaa.descricao;

-- Consulta 3: Verificando as médias e máximas das aulas excelentes
SELECT vae.descricao, vae.media_nota, vaa.nota_maxima
FROM vw_aulas_excelencia vae
JOIN vw_atividades_aula vaa ON vae.descricao = vaa.descricao;

-- Consulta 4: Cruzando professores ativos com sua contagem de turmas
SELECT vpa.nome, vpa.total_planos, vpt.turmas_alocadas
FROM vw_professores_ativos vpa
JOIN vw_professores_turmas vpt ON vpa.nome = vpt.nome;

-- Consulta 5: Buscando as métricas detalhadas dos professores ativos
SELECT vpa.nome, vpa.total_planos, vpm.matricula
FROM vw_professores_ativos vpa
JOIN vw_professores_metricas vpm ON vpa.nome = vpm.nome;

-- Consulta 6: Detalhando as turmas através da métrica de professores
SELECT vpt.nome, vpt.turmas_alocadas, vpm.matricula
FROM vw_professores_turmas vpt
JOIN vw_professores_metricas vpm ON vpt.nome = vpm.nome;

-- Consulta 7: Cruzando o resumo das UCs com os cursos mais ativos
SELECT vru.curso, vru.total_ucs, vca.soma_avaliacoes
FROM vw_resumo_ucs vru
JOIN vw_cursos_ativos vca ON vru.curso = vca.nome;

-- Consulta 8: Cruzando o resumo das UCs com a visão detalhada (híbrida)
SELECT vru.curso, vru.total_ucs, vdc.objetivo
FROM vw_resumo_ucs vru
JOIN vw_detalhe_cursos_view vdc ON vru.curso = vdc.curso;

-- Consulta 9: Pegando a soma das avaliações e os objetivos dos cursos
SELECT vca.nome AS curso, vca.soma_avaliacoes, vdc.objetivo
FROM vw_cursos_ativos vca
JOIN vw_detalhe_cursos_view vdc ON vca.nome = vdc.curso;

-- Consulta 10: Cruzamento livre (CROSS JOIN) entre turmas e professores para relatórios matriciais
SELECT vpe.cod_turma, vpe.menor_nota, vpa.nome AS professor_ativo
FROM vw_planos_ensino_detalhe vpe
CROSS JOIN vw_professores_ativos vpa
ORDER BY vpe.cod_turma;