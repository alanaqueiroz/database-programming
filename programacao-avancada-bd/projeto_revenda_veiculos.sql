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
    v_contador NUMBER(1); --FAZER NO MINIMO O LOG DE EXECUCAO SIMPLES
    v_contador_nome NUMBER(1);
    v_retorno NUMBER := 0;
BEGIN
    /*IF p_id_fab IS NULL THEN
        v_retorno = -1; --NENHUM CÓDIGO FOI INFORMADO                              
    END IF;*/

    IF p_id_fab != trunc(p_id_fab) THEN
        v_retorno := -1; --O VALOR INFORMADO NÃO É UM INTEIRO                              
    END IF;

    /*IF p_nome IS NULL THEN
        v_retorno = -2; --NENHUM NOME FOI INFORMADO
    END IF;*/

    SELECT COUNT(*) 
    INTO v_contador
    FROM fabricante 
    WHERE id_fab = p_id_fab;

    SELECT COUNT(nome)
    INTO v_contador_nome
    FROM fabricante 
    WHERE nome = p_nome;

    IF v_contador = 1 THEN
        v_retorno := -2; --O ID JÁ EXISTE
    ELSE
        IF v_contador_nome = 1 THEN
            v_retorno := -3; --O NOME INFORMADO JÁ EXISTE NA TABELA
        ELSE
            IF p_id_fab IS NULL OR p_id_fab NOT BETWEEN 1 AND 9999 THEN
                v_retorno := -4; --O ID INFORMADO NÃO FOI INFORMADO OU NÃO ESTÁ ENTRE O INTERVALO PERMITIDO (1 E 9999)
            ELSE 
                IF p_nome IS NULL OR LENGTH(p_nome) > 120 THEN --MAIOR OU IGUAL***
                    v_retorno := -5; --NOME NULO OU MAIOR DO QUE O PERMITIDO (120 CARACTERES)
                ELSE
                    IF LENGTH(p_apelido) > 60 THEN
                        v_retorno := -6; --APELIDO MAIOR DO QUE O PERMITIDO (60 CARACTERES)
                    ELSE
                        INSERT INTO fabricante (id_fab, nome, apelido)
                        values (p_id_fab, p_nome, p_apelido);

                        --v_retorno = --SUCESSO NA OPERACAO
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
    COMMIT;
    RETURN v_retorno;

    EXCEPTION
        WHEN OTHERS THEN 
            ROLLBACK;

            /*V_ERRO := SQLCODE;
            V_DESC_ERRO := SQLERRM;

            INSERT INTO LOG_EXECUCAO(ID_LOG, ERRO, DESC_ERRO, LINHA_ERRO, NOME_CODIGO, PARAMETROS, DTH_ERRO, USUARIO, RESOLVIDO, DESC_RESOLVIDO)
            VALUES(
                SEQ_LOG_EXECUCAO.NEXTVAL,
                V_ERRO,
                V_DESC_ERRO,
                DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                'FUNC_INSERIRFABRICANTE',
                'P_PERC = '||P_PERC,
                SYSDATE,
                USER,
                'N',
                NULL
            );
            COMMIT;*/
            RETURN SQLCODE;
END;
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