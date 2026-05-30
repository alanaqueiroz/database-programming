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

/**
 * ============================================================================
 * PROJETO.............: REVENDA DE VEICULOS
 * FUNCAO..............: FUNC_INSERIRFABRICANTE
 * TIPO................: FUNCTION
 * OBJETIVO............: INSERIR UM NOVO FABRICANTE REALIZANDO VALIDACOES
 *                       DE REGRA DE NEGOCIO E CONTROLE DE DUPLICIDADE.
 *
 * AUTOR...............: ALANA QUEIROZ BRAGA
 * DATA................: 30/05/2026
 * ============================================================================
 *
 * DESCRICAO:
 * ---------------------------------------------------------------------------
 * ESTA FUNCAO REALIZA A INSERCAO DE UM NOVO FABRICANTE NA TABELA
 * FABRICANTE.
 *
 * A FUNCAO EXECUTA VALIDACOES DE:
 *
 * - PREENCHIMENTO DOS CAMPOS OBRIGATORIOS
 * - TAMANHO DOS CAMPOS
 * - INTERVALO NUMERICO
 * - VALIDACAO DE NUMERO INTEIRO
 * - DUPLICIDADE DE CODIGO
 * - DUPLICIDADE DE NOME
 *
 * A VALIDACAO DE NOME DUPLICADO IGNORA:
 *
 * - ACENTOS
 * - ESPACOS EM BRANCO NAS EXTREMIDADES
 * - DIFERENCA ENTRE LETRAS MAIUSCULAS E MINUSCULAS
 *
 * O CAMPO APELIDO E OPCIONAL.
 *
 * EM CASO DE ERRO INESPERADO, A EXCEPTION GRAVA O ERRO NA
 * TABELA LOG_EXECUCAO.
 *
 * A FUNCAO UTILIZA:
 *
 * - COMMIT EM CASO DE SUCESSO
 * - ROLLBACK EM CASO DE ERRO
 *
 * ---------------------------------------------------------------------------
 * PARAMETROS:
 * ---------------------------------------------------------------------------
 *
 * @param P_ID_FAB
 *        CODIGO IDENTIFICADOR DO FABRICANTE.
 *        O VALOR DEVE SER:
 *        - NUMERICO
 *        - INTEIRO
 *        - ENTRE 1 E 9999
 *
 * @param P_NOME
 *        NOME DO FABRICANTE.
 *        REGRAS:
 *        - OBRIGATORIO
 *        - TAMANHO MAXIMO DE 120 CARACTERES
 *        - NAO PODE EXISTIR DUPLICADO
 *
 * @param P_APELIDO
 *        APELIDO DO FABRICANTE.
 *        REGRAS:
 *        - OPCIONAL
 *        - TAMANHO MAXIMO DE 60 CARACTERES
 *
 * ---------------------------------------------------------------------------
 * RETORNO:
 * ---------------------------------------------------------------------------
 *
 * @return NUMBER
 *
 *  0  = FABRICANTE INSERIDO COM SUCESSO
 *
 * -1  = ID NAO INFORMADO
 *       O PARAMETRO P_ID_FAB FOI ENVIADO NULO.
 *
 * -2  = ID INFORMADO NAO E INTEIRO
 *       O VALOR INFORMADO POSSUI CASAS DECIMAIS.
 *
 * -3  = ID FORA DA FAIXA PERMITIDA
 *       O ID DEVE ESTAR ENTRE 1 E 9999.
 *
 * -4  = ID JA EXISTE
 *       JA EXISTE UM FABRICANTE COM O MESMO ID.
 *
 * -5  = NOME NAO INFORMADO
 *       O PARAMETRO P_NOME FOI ENVIADO NULO OU VAZIO.
 *
 * -6  = NOME MAIOR QUE 120 CARACTERES
 *       O NOME INFORMADO EXCEDE O TAMANHO MAXIMO.
 *
 * -7  = NOME JA EXISTE
 *       JA EXISTE UM FABRICANTE COM O MESMO NOME.
 *
 * -8  = APELIDO MAIOR QUE 60 CARACTERES
 *       O APELIDO INFORMADO EXCEDE O TAMANHO MAXIMO.
 *
 * SQLCODE = ERRO INESPERADO
 *           QUALQUER ERRO NAO TRATADO PELAS VALIDACOES.
 *
 * ---------------------------------------------------------------------------
 * EXEMPLO DE UTILIZACAO:
 * ---------------------------------------------------------------------------
 *
 * DECLARE
 *     V_RETORNO NUMBER;
 * BEGIN
 *
 *     V_RETORNO := FUNC_INSERIRFABRICANTE(
 *         1,
 *         'TOYOTA',
 *         'TOY'
 *     );
 *
 *     DBMS_OUTPUT.PUT_LINE(
 *         'RETORNO = ' || V_RETORNO
 *     );
 *
 * END;
 *
 * ============================================================================
 */

/**
 * ============================================================================
 * TABELA: LOG_EXECUCAO
 * ----------------------------------------------------------------------------
 * Objetivo:
 * Registrar exceções inesperadas ocorridas durante a execução de códigos PL/SQL.
 * ============================================================================
 */
DROP TABLE LOG_EXECUCAO;
DROP SEQUENCE SEQ_LOG_EXECUCAO;

/**
 * ============================================================================
 * TABELA: LOG_EXECUCAO
 * ============================================================================
 * Finalidade:
 * Armazenar informações sobre exceções inesperadas ocorridas durante a
 * execução de procedimentos, funções e demais códigos PL/SQL.
 *
 * Informações registradas:
 * - Código do erro (SQLCODE)
 * - Descrição do erro (SQLERRM)
 * - Linha da ocorrência
 * - Nome do código executado
 * - Parâmetros recebidos
 * - Data e hora da ocorrência
 * - Usuário responsável pela execução
 * - Status de resolução
 * ============================================================================
 */
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

/**
 * ============================================================================
 * SEQUENCE: SEQ_LOG_EXECUCAO
 * ============================================================================
 * Finalidade:
 * Gerar identificadores únicos para os registros da tabela LOG_EXECUCAO.
 * ============================================================================
 */
CREATE SEQUENCE SEQ_LOG_EXECUCAO
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

/**
 * ============================================================================
 * FUNCTION: FUNC_INSERIRFABRICANTE
 * ============================================================================
 * Finalidade:
 * Inserir registros na tabela FABRICANTE aplicando todas as regras de negócio
 * definidas para o cadastro de fabricantes.
 *
 * Parâmetros:
 * @param P_ID_FAB   Código do fabricante.
 * @param P_NOME     Nome do fabricante.
 * @param P_APELIDO  Apelido do fabricante (opcional).
 *
 * Validações executadas:
 * - Verificação de preenchimento dos campos obrigatórios.
 * - Verificação do tamanho dos campos.
 * - Validação do intervalo permitido para o código.
 * - Verificação de valor inteiro para o código.
 * - Verificação de duplicidade de código.
 * - Verificação de duplicidade de nome.
 *
 * Retornos:
 *  0  = Fabricante inserido com sucesso.
 * -1  = Código não informado.
 * -2  = Código informado não é inteiro.
 * -3  = Código fora da faixa permitida (1 a 9999).
 * -4  = Código já cadastrado.
 * -5  = Nome não informado.
 * -6  = Nome excede 120 caracteres.
 * -7  = Nome já cadastrado.
 * -8  = Apelido excede 60 caracteres.
 *
 * Tratamento de exceções:
 * Qualquer erro não previsto nas validações será registrado na tabela
 * LOG_EXECUCAO para auditoria e posterior análise da equipe de suporte.
 * ============================================================================
 */
CREATE OR REPLACE FUNCTION FUNC_INSERIRFABRICANTE (
    P_ID_FAB   IN FABRICANTE.ID_FAB%TYPE,
    P_NOME     IN FABRICANTE.NOME%TYPE,
    P_APELIDO  IN FABRICANTE.APELIDO%TYPE
)
RETURN NUMBER
IS
    V_RETORNO      NUMBER(5);
    V_QTDE         NUMBER;
    V_ERRO         NUMBER;
    V_DESC_ERRO    VARCHAR2(1000);

BEGIN

    IF P_ID_FAB IS NULL THEN

        V_RETORNO := -1;

    ELSIF P_ID_FAB <> TRUNC(P_ID_FAB) THEN

        V_RETORNO := -2;

    ELSIF P_ID_FAB NOT BETWEEN 1 AND 9999 THEN

        V_RETORNO := -3;

    ELSE

        SELECT COUNT(*)
        INTO V_QTDE
        FROM FABRICANTE
        WHERE ID_FAB = P_ID_FAB;

        IF V_QTDE > 0 THEN

            V_RETORNO := -4;

        ELSE

            IF P_NOME IS NULL
               OR LENGTH(TRIM(P_NOME)) = 0 THEN

                V_RETORNO := -5;

            ELSIF LENGTH(TRIM(P_NOME)) > 120 THEN

                V_RETORNO := -6;

            ELSE

                SELECT COUNT(*)
                INTO V_QTDE
                FROM FABRICANTE
                WHERE
                TRANSLATE(
                    UPPER(TRIM(NOME)),
                    'ÁÉÍÓÚÂÊÎÔÛÃÕÀÈÌÒÙÄËÏÖÜÇ',
                    'AEIOUAEIOUAOAEIOUAEIOUC'
                )
                =
                TRANSLATE(
                    UPPER(TRIM(P_NOME)),
                    'ÁÉÍÓÚÂÊÎÔÛÃÕÀÈÌÒÙÄËÏÖÜÇ',
                    'AEIOUAEIOUAOAEIOUAEIOUC'
                );

                IF V_QTDE > 0 THEN

                    V_RETORNO := -7;

                ELSE

                    IF P_APELIDO IS NOT NULL
                       AND LENGTH(TRIM(P_APELIDO)) > 60 THEN

                        V_RETORNO := -8;

                    ELSE

                        INSERT INTO FABRICANTE (
                            ID_FAB,
                            NOME,
                            APELIDO
                        )
                        VALUES (
                            P_ID_FAB,
                            TRIM(P_NOME),
                            TRIM(P_APELIDO)
                        );

                        V_RETORNO := 0;

                    END IF;

                END IF;

            END IF;

        END IF;

    END IF;

    COMMIT;

    RETURN V_RETORNO;

EXCEPTION

    WHEN OTHERS THEN

        ROLLBACK;

        V_ERRO := SQLCODE;
        V_DESC_ERRO := SQLERRM;

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
            V_ERRO,
            V_DESC_ERRO,
            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            'FUNC_INSERIRFABRICANTE',
            'P_ID_FAB = ' || P_ID_FAB ||
            ' | P_NOME = ' || P_NOME ||
            ' | P_APELIDO = ' || P_APELIDO,
            SYSDATE,
            USER,
            'N',
            NULL
        );

        COMMIT;

        RETURN SQLCODE;

END;
/

/**
 * ============================================================================
 * TESTES DA FUNCTION: FUNC_INSERIRFABRICANTE
 * ============================================================================
 * Finalidade:
 * Validar as regras de negócio implementadas na função
 * FUNC_INSERIRFABRICANTE.
 *
 * Cenários testados:
 * 1. Inserção válida de fabricante.
 * 2. Tentativa de cadastro com código já existente.
 * 3. Tentativa de cadastro com nome já existente.
 * 4. Tentativa de cadastro com nome duplicado contendo acentuação.
 * 5. Tentativa de cadastro com código decimal.
 * 6. Tentativa de cadastro sem informar nome.
 * 7. Tentativa de cadastro com apelido acima do tamanho permitido.
 *
 * Resultado esperado:
 * Cada execução deve retornar o código correspondente à regra validada,
 * conforme documentação da função.
 * ============================================================================
 */
SET SERVEROUTPUT ON;

DECLARE

    V_RETORNO NUMBER;

BEGIN

    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    DBMS_OUTPUT.PUT_LINE('TESTE 1 - INSERCAO VALIDA');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');

    V_RETORNO := FUNC_INSERIRFABRICANTE(
        1,
        'TOYOTA',
        'TOY'
    );

    DBMS_OUTPUT.PUT_LINE('RETORNO = ' || V_RETORNO);

    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    DBMS_OUTPUT.PUT_LINE('TESTE 2 - ID DUPLICADO');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');

    V_RETORNO := FUNC_INSERIRFABRICANTE(
        1,
        'HONDA',
        'HON'
    );

    DBMS_OUTPUT.PUT_LINE('RETORNO = ' || V_RETORNO);

    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    DBMS_OUTPUT.PUT_LINE('TESTE 3 - NOME DUPLICADO');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');

    V_RETORNO := FUNC_INSERIRFABRICANTE(
        2,
        'TOYOTA',
        'TYT'
    );

    DBMS_OUTPUT.PUT_LINE('RETORNO = ' || V_RETORNO);

    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    DBMS_OUTPUT.PUT_LINE('TESTE 4 - NOME DUPLICADO COM ACENTO');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');

    V_RETORNO := FUNC_INSERIRFABRICANTE(
        3,
        'TÓYÓTÁ',
        'TOY'
    );

    DBMS_OUTPUT.PUT_LINE('RETORNO = ' || V_RETORNO);

    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    DBMS_OUTPUT.PUT_LINE('TESTE 5 - ID FLOAT');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');

    V_RETORNO := FUNC_INSERIRFABRICANTE(
        1.5,
        'BMW',
        'BMW'
    );

    DBMS_OUTPUT.PUT_LINE('RETORNO = ' || V_RETORNO);

    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    DBMS_OUTPUT.PUT_LINE('TESTE 6 - NOME NULO');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');

    V_RETORNO := FUNC_INSERIRFABRICANTE(
        4,
        NULL,
        'TES'
    );

    DBMS_OUTPUT.PUT_LINE('RETORNO = ' || V_RETORNO);

    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    DBMS_OUTPUT.PUT_LINE('TESTE 7 - APELIDO MAIOR QUE 60');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');

    V_RETORNO := FUNC_INSERIRFABRICANTE(
        5,
        'TESLA',
        RPAD('A', 61, 'A')
    );

    DBMS_OUTPUT.PUT_LINE('RETORNO = ' || V_RETORNO);

END;
/