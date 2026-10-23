-- ============================================================
-- Sistema de Gestão de Pesquisas por Questionários — Fatec Lins
-- Script de criação do banco (MySQL 8)
-- Gerado a partir do MER (mesma definição do diagrama)
-- ============================================================

CREATE DATABASE IF NOT EXISTS gestao_pesquisas
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;
USE gestao_pesquisas;

CREATE TABLE perfil (
    id_perfil INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(40) NOT NULL,
    descricao VARCHAR(200) NULL,
    CONSTRAINT pk_perfil PRIMARY KEY (id_perfil),
    CONSTRAINT uq_perfil_nome UNIQUE (nome)
);

CREATE TABLE usuario (
    id_usuario INT NOT NULL AUTO_INCREMENT,
    id_perfil INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL,
    senha_hash CHAR(64) NOT NULL,
    ativo BOOLEAN NOT NULL,
    data_cadastro DATETIME NOT NULL,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email UNIQUE (email),
    CONSTRAINT fk_usuario_id_perfil FOREIGN KEY (id_perfil)
        REFERENCES perfil (id_perfil)
);

CREATE TABLE campus (
    id_campus INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(80) NOT NULL,
    cidade VARCHAR(60) NOT NULL,
    CONSTRAINT pk_campus PRIMARY KEY (id_campus),
    CONSTRAINT uq_campus_nome UNIQUE (nome)
);

CREATE TABLE pesquisa (
    id_pesquisa INT NOT NULL AUTO_INCREMENT,
    id_campus INT NOT NULL,
    id_usuario INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    descricao TEXT NULL,
    data_inicio DATETIME NOT NULL,
    data_fim DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL,
    data_cadastro DATETIME NOT NULL,
    CONSTRAINT pk_pesquisa PRIMARY KEY (id_pesquisa),
    CONSTRAINT ck_pesquisa_1 CHECK (data_fim > data_inicio),
    CONSTRAINT ck_pesquisa_2 CHECK (status IN ('Rascunho','Em análise','Aprovada','Reprovada','Ativa','Encerrada')),
    CONSTRAINT fk_pesquisa_id_campus FOREIGN KEY (id_campus)
        REFERENCES campus (id_campus),
    CONSTRAINT fk_pesquisa_id_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
);

CREATE TABLE aprovacao (
    id_aprovacao INT NOT NULL AUTO_INCREMENT,
    id_pesquisa INT NOT NULL,
    id_usuario INT NOT NULL,
    decisao VARCHAR(10) NOT NULL,
    justificativa VARCHAR(500) NULL,
    data_decisao DATETIME NOT NULL,
    CONSTRAINT pk_aprovacao PRIMARY KEY (id_aprovacao),
    CONSTRAINT ck_aprovacao_1 CHECK (decisao IN ('Aprovada','Reprovada')),
    CONSTRAINT ck_aprovacao_2 CHECK (decisao = 'Aprovada' OR CHAR_LENGTH(justificativa) >= 10),
    CONSTRAINT fk_aprovacao_id_pesquisa FOREIGN KEY (id_pesquisa)
        REFERENCES pesquisa (id_pesquisa),
    CONSTRAINT fk_aprovacao_id_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
);

CREATE TABLE categoria (
    id_categoria INT NOT NULL AUTO_INCREMENT,
    id_pesquisa INT NOT NULL,
    nome VARCHAR(60) NOT NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_1 UNIQUE (id_pesquisa, nome),
    CONSTRAINT fk_categoria_id_pesquisa FOREIGN KEY (id_pesquisa)
        REFERENCES pesquisa (id_pesquisa)
);

CREATE TABLE questionario (
    id_questionario INT NOT NULL AUTO_INCREMENT,
    id_categoria INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    status VARCHAR(20) NOT NULL,
    data_criacao DATETIME NOT NULL,
    CONSTRAINT pk_questionario PRIMARY KEY (id_questionario),
    CONSTRAINT uq_questionario_id_categoria UNIQUE (id_categoria),
    CONSTRAINT fk_questionario_id_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria)
);

CREATE TABLE pergunta (
    id_pergunta INT NOT NULL AUTO_INCREMENT,
    id_questionario INT NOT NULL,
    ordem SMALLINT NOT NULL,
    enunciado VARCHAR(500) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    obrigatoria BOOLEAN NOT NULL,
    CONSTRAINT pk_pergunta PRIMARY KEY (id_pergunta),
    CONSTRAINT uq_pergunta_1 UNIQUE (id_questionario, ordem),
    CONSTRAINT ck_pergunta_2 CHECK (tipo IN ('Unica','Multipla','Escala','Aberta')),
    CONSTRAINT fk_pergunta_id_questionario FOREIGN KEY (id_questionario)
        REFERENCES questionario (id_questionario)
);

CREATE TABLE alternativa (
    id_alternativa INT NOT NULL AUTO_INCREMENT,
    id_pergunta INT NOT NULL,
    ordem SMALLINT NOT NULL,
    texto VARCHAR(150) NOT NULL,
    CONSTRAINT pk_alternativa PRIMARY KEY (id_alternativa),
    CONSTRAINT uq_alternativa_1 UNIQUE (id_pergunta, ordem),
    CONSTRAINT fk_alternativa_id_pergunta FOREIGN KEY (id_pergunta)
        REFERENCES pergunta (id_pergunta)
);

CREATE TABLE lote_senha (
    id_lote INT NOT NULL AUTO_INCREMENT,
    id_categoria INT NOT NULL,
    id_usuario INT NOT NULL,
    quantidade INT NOT NULL,
    formato_exportacao VARCHAR(5) NOT NULL,
    data_geracao DATETIME NOT NULL,
    CONSTRAINT pk_lote_senha PRIMARY KEY (id_lote),
    CONSTRAINT ck_lote_senha_1 CHECK (quantidade > 0),
    CONSTRAINT ck_lote_senha_2 CHECK (formato_exportacao IN ('PDF','CSV')),
    CONSTRAINT fk_lote_senha_id_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria),
    CONSTRAINT fk_lote_senha_id_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
);

CREATE TABLE senha (
    id_senha INT NOT NULL AUTO_INCREMENT,
    id_lote INT NOT NULL,
    senha_hash CHAR(64) NOT NULL,
    status VARCHAR(15) NOT NULL,
    data_utilizacao DATETIME NULL,
    CONSTRAINT pk_senha PRIMARY KEY (id_senha),
    CONSTRAINT uq_senha_senha_hash UNIQUE (senha_hash),
    CONSTRAINT ck_senha_1 CHECK (status IN ('Não utilizada','Utilizada')),
    CONSTRAINT fk_senha_id_lote FOREIGN KEY (id_lote)
        REFERENCES lote_senha (id_lote)
);

CREATE TABLE participacao (
    id_participacao INT NOT NULL AUTO_INCREMENT,
    id_questionario INT NOT NULL,
    status VARCHAR(15) NOT NULL,
    data_inicio DATETIME NOT NULL,
    data_envio DATETIME NULL,
    CONSTRAINT pk_participacao PRIMARY KEY (id_participacao),
    CONSTRAINT ck_participacao_1 CHECK (status IN ('Rascunho','Concluída')),
    CONSTRAINT fk_participacao_id_questionario FOREIGN KEY (id_questionario)
        REFERENCES questionario (id_questionario)
);

CREATE TABLE resposta (
    id_resposta INT NOT NULL AUTO_INCREMENT,
    id_participacao INT NOT NULL,
    id_pergunta INT NOT NULL,
    id_alternativa INT NULL,
    valor_escala SMALLINT NULL,
    texto_resposta VARCHAR(500) NULL,
    CONSTRAINT pk_resposta PRIMARY KEY (id_resposta),
    CONSTRAINT ck_resposta_1 CHECK (valor_escala IS NULL OR valor_escala BETWEEN 1 AND 5),
    CONSTRAINT fk_resposta_id_participacao FOREIGN KEY (id_participacao)
        REFERENCES participacao (id_participacao),
    CONSTRAINT fk_resposta_id_pergunta FOREIGN KEY (id_pergunta)
        REFERENCES pergunta (id_pergunta),
    CONSTRAINT fk_resposta_id_alternativa FOREIGN KEY (id_alternativa)
        REFERENCES alternativa (id_alternativa)
);

CREATE TABLE exportacao (
    id_exportacao INT NOT NULL AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_pesquisa INT NULL,
    formato VARCHAR(5) NOT NULL,
    periodo_inicio DATE NULL,
    periodo_fim DATE NULL,
    data_hora DATETIME NOT NULL,
    CONSTRAINT pk_exportacao PRIMARY KEY (id_exportacao),
    CONSTRAINT ck_exportacao_1 CHECK (formato IN ('CSV','XLSX')),
    CONSTRAINT fk_exportacao_id_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario),
    CONSTRAINT fk_exportacao_id_pesquisa FOREIGN KEY (id_pesquisa)
        REFERENCES pesquisa (id_pesquisa)
);

CREATE TABLE log_auditoria (
    id_log BIGINT NOT NULL AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    acao VARCHAR(200) NOT NULL,
    entidade_afetada VARCHAR(40) NULL,
    endereco_ip VARCHAR(45) NULL,
    data_hora DATETIME NOT NULL,
    CONSTRAINT pk_log_auditoria PRIMARY KEY (id_log),
    CONSTRAINT fk_log_auditoria_id_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
);

CREATE TABLE servico (
    id_servico INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(80) NOT NULL,
    status VARCHAR(15) NOT NULL,
    uptime_30d DECIMAL(5,2) NULL,
    CONSTRAINT pk_servico PRIMARY KEY (id_servico),
    CONSTRAINT uq_servico_nome UNIQUE (nome),
    CONSTRAINT ck_servico_1 CHECK (status IN ('Operacional','Degradado','Fora do ar'))
);

CREATE TABLE verificacao_servico (
    id_verificacao INT NOT NULL AUTO_INCREMENT,
    id_servico INT NOT NULL,
    id_usuario INT NOT NULL,
    observacao VARCHAR(500) NULL,
    data_hora DATETIME NOT NULL,
    CONSTRAINT pk_verificacao_servico PRIMARY KEY (id_verificacao),
    CONSTRAINT fk_verificacao_servico_id_servico FOREIGN KEY (id_servico)
        REFERENCES servico (id_servico),
    CONSTRAINT fk_verificacao_servico_id_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
);

CREATE TABLE chamado (
    id_chamado INT NOT NULL AUTO_INCREMENT,
    id_servico INT NOT NULL,
    id_usuario INT NOT NULL,
    severidade VARCHAR(10) NOT NULL,
    descricao TEXT NOT NULL,
    email_retorno VARCHAR(120) NOT NULL,
    status VARCHAR(20) NOT NULL,
    data_abertura DATETIME NOT NULL,
    prazo_sla DATETIME NULL,
    data_resolucao DATETIME NULL,
    CONSTRAINT pk_chamado PRIMARY KEY (id_chamado),
    CONSTRAINT ck_chamado_1 CHECK (severidade IN ('Crítica','Média','Baixa')),
    CONSTRAINT fk_chamado_id_servico FOREIGN KEY (id_servico)
        REFERENCES servico (id_servico),
    CONSTRAINT fk_chamado_id_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
);

CREATE TABLE verificacao_conformidade (
    id_verif_conf INT NOT NULL AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    data_hora DATETIME NOT NULL,
    CONSTRAINT pk_verificacao_conformidade PRIMARY KEY (id_verif_conf),
    CONSTRAINT fk_verificacao_conformidade_id_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
);

CREATE TABLE item_conformidade (
    id_item INT NOT NULL AUTO_INCREMENT,
    id_verif_conf INT NOT NULL,
    item_verificado VARCHAR(100) NOT NULL,
    status VARCHAR(15) NOT NULL,
    observacao VARCHAR(300) NULL,
    CONSTRAINT pk_item_conformidade PRIMARY KEY (id_item),
    CONSTRAINT ck_item_conformidade_1 CHECK (status IN ('Conforme','Não conforme')),
    CONSTRAINT fk_item_conformidade_id_verif_conf FOREIGN KEY (id_verif_conf)
        REFERENCES verificacao_conformidade (id_verif_conf)
);

-- Perfis de acesso do sistema
INSERT INTO perfil (nome, descricao) VALUES
    ('Administrador', 'Cria e gerencia pesquisas, categorias, questionários, senhas e relatórios'),
    ('Secretaria', 'Aprova pesquisas e analisa relatórios institucionais'),
    ('Analista de Dados', 'Analisa resultados e exporta dados anonimizados'),
    ('Suporte Técnico', 'Mantém o sistema e resolve chamados'),
    ('Auditor', 'Audita dados e verifica conformidade com a LGPD');
