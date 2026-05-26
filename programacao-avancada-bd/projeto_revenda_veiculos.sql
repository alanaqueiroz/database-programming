/* ATIVIDADE - Trabalho Final (Projeto Revenda de Veículos)
1 - [FUNCTION] Criar uma função que denominada FUNC_INSERIRFABRICANTE, que receberá todos os campos da tabela FABRICANTE como parâmetros de entrada. 
Todos os parâmetros devem ser verificados quanto ao seu tamanho (tanto campos numéricos quanto textuais), lembrando que o campo APELIDO pode ser nulo. 
Verificar se o código já existe na tabela, caso exista retornar um código para a situação. 
A função não deve permitir que o campo nome tenha valor repetido dentro da tabela. 
Se todas as regras forem satisfeitas o parâmetro de retorno deve ser o valor 0 (zero). 
Caso contrário deve retornar um código de “erro” do procedimento, iniciando no -1, -2, -3…-n. 
Documentar cada código, juntamente com uma explicação do funcionamento do código para ser entregue para a  equipe de TI da empresa que está adquirindo 
o código (uma boa documentação é aquela que não gere dúvida para o uso do código). Por fim, a função deve implementar a divisão EXCEPTION, juntamente 
com a tabela LOG_EXECUCAO, para que grave exceções inesperadas.
*/

/* DDL Padrão */

DROP TABLE cliente CASCADE CONSTRAINTS;
DROP TABLE cliente_fisica CASCADE CONSTRAINTS;
DROP TABLE cliente_juridica CASCADE CONSTRAINTS;
DROP TABLE fabricante CASCADE CONSTRAINTS;
DROP TABLE modelo CASCADE CONSTRAINTS;
DROP TABLE veiculo CASCADE CONSTRAINTS;
DROP TABLE venda CASCADE CONSTRAINTS;
DROP TABLE versao CASCADE CONSTRAINTS;
 
CREATE TABLE cliente (
    id_cli       NUMBER(10) NOT NULL,
    nome_cliente VARCHAR2(120) NOT NULL,
    tipo         NUMBER(1) NOT NULL,
    endereco     VARCHAR2(120) NOT NULL,
    numero       VARCHAR2(10) NOT NULL,
    complemento  VARCHAR2(120),
    bairro       VARCHAR2(120) NOT NULL,
    cidade       VARCHAR2(120) NOT NULL,
    estado       CHAR(2) NOT NULL
);
 
ALTER TABLE cliente
    ADD CHECK ( tipo IN ( 1, 2 ) );
 
ALTER TABLE cliente ADD CONSTRAINT cliente_pk PRIMARY KEY ( id_cli );
 
CREATE TABLE cliente_fisica (
    cliente_id_cli  NUMBER(10) NOT NULL PRIMARY KEY,
    cpf             CHAR(14) NOT NULL,
    "NOME COMPLETO" VARCHAR2(120) NOT NULL
);
 
CREATE UNIQUE INDEX cliente_fisica_cpf_idx ON
    cliente_fisica (
        cpf
    ASC );
 
CREATE TABLE cliente_juridica (
    cliente_id_cli     NUMBER(10) NOT NULL PRIMARY KEY,
    razao_social       VARCHAR2(120) NOT NULL,
    nome_fantasia      VARCHAR2(120) NOT NULL,
    cnpj               CHAR(18) NOT NULL,
    inscricao_estadual CHAR(15)
);
 
CREATE UNIQUE INDEX cliente_juridica_cnpj_idx ON
    cliente_juridica (
        cnpj
    ASC );
 
CREATE TABLE fabricante (
    id_fab  NUMBER(4) NOT NULL,
    nome    VARCHAR2(120) NOT NULL,
    apelido VARCHAR2(60)
);
 
CREATE UNIQUE INDEX fabricante_nome_idx ON
    fabricante (
        nome
    ASC );
 
ALTER TABLE fabricante ADD CONSTRAINT fabricante_pk PRIMARY KEY ( id_fab );
 
CREATE TABLE modelo (
    id_fab NUMBER(4) NOT NULL,
    id_mod NUMBER(5) NOT NULL,
    nome   VARCHAR2(120)
);
 
ALTER TABLE modelo ADD CONSTRAINT modelo_pk PRIMARY KEY ( id_mod,
                                                          id_fab );
 

CREATE TABLE veiculo (
    id_vei           NUMBER(10) NOT NULL,
    ano_fabricacao   NUMBER(4) NOT NULL,
    ano_modelo       NUMBER(4) NOT NULL,
    chassi           CHAR(17) NOT NULL,
    placa            CHAR(8),
    cor_predominante VARCHAR2(60) NOT NULL,
    id_fab           NUMBER(4) NOT NULL,
    id_mod           NUMBER(5) NOT NULL,
    id_ver           NUMBER(6) NOT NULL,
    preco_compra     NUMBER(12, 2) NOT NULL,
    preco_venda      NUMBER(12, 2) NOT NULL
);
 
CREATE UNIQUE INDEX veiculo_chassi_idx ON
    veiculo (
        chassi
    ASC );
 
ALTER TABLE veiculo ADD CONSTRAINT veiculo_pk PRIMARY KEY ( id_vei );
 
CREATE TABLE venda (
    id_vei      NUMBER(10) NOT NULL,
    id_cli      NUMBER(10) NOT NULL,
    data_venda  DATE NOT NULL,
    valor_venda NUMBER(12, 2) NOT NULL
);
 
ALTER TABLE venda ADD CONSTRAINT venda_pk PRIMARY KEY ( id_vei,
                                                        id_cli );
 
CREATE TABLE versao (
    id_fab NUMBER(4) NOT NULL,
    id_mod NUMBER(5) NOT NULL,
    id_ver NUMBER(6) NOT NULL,
    nome   VARCHAR2(120) NOT NULL
);
 
ALTER TABLE versao
    ADD CONSTRAINT versao_pk PRIMARY KEY ( id_ver,
                                           id_fab,
                                           id_mod );
 
ALTER TABLE cliente_fisica
    ADD CONSTRAINT cliente_fisica_cliente_fk FOREIGN KEY ( cliente_id_cli )
        REFERENCES cliente ( id_cli );
 
ALTER TABLE cliente_juridica
    ADD CONSTRAINT cliente_juridica_cliente_fk FOREIGN KEY ( cliente_id_cli )
        REFERENCES cliente ( id_cli );
 
ALTER TABLE modelo
    ADD CONSTRAINT modelo_fabricante_fk FOREIGN KEY ( id_fab )
        REFERENCES fabricante ( id_fab );
 
ALTER TABLE veiculo
    ADD CONSTRAINT veiculo_versao_fk FOREIGN KEY ( id_ver,
                                                   id_fab,
                                                   id_mod )
        REFERENCES versao ( id_ver,
                            id_fab,
                            id_mod );
 
ALTER TABLE venda
    ADD CONSTRAINT venda_cliente_fk FOREIGN KEY ( id_cli )
        REFERENCES cliente ( id_cli );
 
ALTER TABLE venda
    ADD CONSTRAINT venda_veiculo_fk FOREIGN KEY ( id_vei )
        REFERENCES veiculo ( id_vei );
 
ALTER TABLE versao ADD CONSTRAINT versao_modelo_fk FOREIGN KEY ( id_mod, id_fab ) REFERENCES modelo ( id_mod, id_fab );

----------

/* DDL Desenvolvido */

DROP TABLE LOG_EXECUCAO;
DROP SEQUENCE SEQ_LOG_EXECUCAO;

CREATE TABLE LOG_EXECUCAO(
    ID_LOG NUMBER PRIMARY KEY,
    ERRO NUMBER NOT NULL,
    DESC_ERRO VARCHAR2(1000) NOT NULL,
    LINHA_ERRO VARCHAR2(1000) NOT NULL,
    NOME_CODIGO VARCHAR2(30) NOT NULL,
    PARAMETROS VARCHAR2(1000) NOT NULL,
    DTH_ERRO DATE NOT NULL,
    USUARIO VARCHAR2(30) NOT NULL,
    RESOLVIDO CHAR(1) NOT NULL,
    DESC_RESOLVIDO VARCHAR2(1000)
);

CREATE SEQUENCE SEQ_LOG_EXECUCAO
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE FUNCTION FUNC_INSERIRFABRICANTE (p_id_fab fabricante.id_fab%TYPE, p_nome fabricante.nome%TYPE, p_apelido fabricante.apelido%TYPE) 
RETURN NUMBER
IS
    v_qtde          NUMBER;
    v_retorno       NUMBER := 0;

    v_erro          NUMBER;
    v_desc_erro     VARCHAR2(1000);

BEGIN

    ----------------------------------------------------------------
    -- VALIDAÇÃO DO ID
    ----------------------------------------------------------------

    IF p_id_fab IS NULL THEN
        RETURN -1;
    END IF;

    IF p_id_fab <> TRUNC(p_id_fab) THEN
        RETURN -2;
    END IF;

    IF p_id_fab NOT BETWEEN 1 AND 9999 THEN
        RETURN -3;
    END IF;

    SELECT COUNT(*)
    INTO v_qtde
    FROM fabricante
    WHERE id_fab = p_id_fab;

    IF v_qtde > 0 THEN
        RETURN -4;
    END IF;

    ----------------------------------------------------------------
    -- VALIDAÇÃO DO NOME
    ----------------------------------------------------------------

    IF p_nome IS NULL OR TRIM(p_nome) IS NULL THEN
        RETURN -5;
    END IF;

    IF LENGTH(TRIM(p_nome)) > 120 THEN
        RETURN -6;
    END IF;

    ----------------------------------------------------------------
    -- VALIDAÇÃO DE NOME DUPLICADO
    -- IGNORANDO:
    -- ACENTOS
    -- ESPAÇOS NAS PONTAS
    -- MAIÚSCULO/MINÚSCULO
    ----------------------------------------------------------------

    SELECT COUNT(*)
    INTO v_qtde
    FROM fabricante
    WHERE TRANSLATE(
            UPPER(TRIM(nome)),
            'ÁÉÍÓÚÂÊÎÔÛÃÕÀÈÌÒÙÄËÏÖÜÇ',
            'AEIOUAEIOUAOAEIOUAEIOUC'
          )
          =
          TRANSLATE(
            UPPER(TRIM(p_nome)),
            'ÁÉÍÓÚÂÊÎÔÛÃÕÀÈÌÒÙÄËÏÖÜÇ',
            'AEIOUAEIOUAOAEIOUAEIOUC'
          );

    IF v_qtde > 0 THEN
        RETURN -7;
    END IF;

    ----------------------------------------------------------------
    -- VALIDAÇÃO DO APELIDO
    ----------------------------------------------------------------

    IF p_apelido IS NOT NULL THEN

        IF LENGTH(TRIM(p_apelido)) > 60 THEN
            RETURN -8;
        END IF;

    END IF;

    ----------------------------------------------------------------
    -- INSERT
    ----------------------------------------------------------------

    INSERT INTO fabricante (
        id_fab,
        nome,
        apelido
    )
    VALUES (
        p_id_fab,
        TRIM(p_nome),
        TRIM(p_apelido)
    );

    COMMIT;

    RETURN 0;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;

        v_erro := SQLCODE;
        v_desc_erro := SQLERRM;

        INSERT INTO LOG_EXECUCAO (
            ID_LOG,
            ERRO,
            DESC_ERRO,
            LINHA_ERRO,
            NOME_CODIGO,
            PARAMETROS,
            DTH_ERRO,
            USUARIO,
            RESOLVIDO,
            DESC_RESOLVIDO
        )
        VALUES (
            SEQ_LOG_EXECUCAO.NEXTVAL,
            v_erro,
            v_desc_erro,
            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            'FUNC_INSERIRFABRICANTE',
            'P_ID_FAB=' || p_id_fab ||
            ' | P_NOME=' || p_nome ||
            ' | P_APELIDO=' || p_apelido,
            SYSDATE,
            USER,
            'N',
            NULL
        );

        COMMIT;

        RETURN v_erro;

END;
/
-------------------------------------

 INSERT INTO fabricante (id_fab, nome, apelido)
        values (p_id_fab, p_nome, p_apelido)
/*
Validacoes:
-Testar o tamanho dos campos; apelido pode ser nulo, mas os outros n; verificar a existencia do codigo na tabela; validar tamanho do id (1 a 9999); o campo apelido pode ser nulo;
-Não deve permitir que o campo nome tenha valor repetido dentro da tabela. 
-TESTAR SE O NUMERO INFORMADO É FLOAT


 --RE-ENUMERAR OS ERROS
*/

 /*DECLARE
    RETORNO NUMBER(5);
BEGIN
    RETORNO := FUNC_INSERIRFABRICANTE(1, 'ALINE', 'ALINE');
    DBMS_OUTPUT.PUT_LINE('DO CODIGO DA CHAMADA -> RETORNO = '||RETORNO);
END;*/