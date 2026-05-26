/*Atividade 1 do Trabalho Final
1 - [FUNCTION] Criar uma função que denominada FUNC_INSERIRFABRICANTE, que receberá todos os campos da tabela FABRICANTE como parâmetros de entrada. 
Todos os parâmetros devem ser verificados quanto ao seu tamanho (tanto campos numéricos quanto textuais), lembrando que o campo APELIDO pode ser nulo. 
Verificar se o código já existe na tabela, caso exista retornar um código para a situação. 
A função não deve permitir que o campo nome tenha valor repetido dentro da tabela. 
Se todas as regras forem satisfeitas o parâmetro de retorno deve ser o valor 0 (zero). 
Caso contrário deve retornar um código de “erro” do procedimento, iniciando no -1, -2, -3…-n. 
Documentar cada código, juntamente com uma explicação do funcionamento do código para ser entregue para a  equipe de TI da empresa que está adquirindo 
o código (uma boa documentação é aquela que não gere dúvida para o uso do código). Por fim, a função deve implementar a divisão EXCEPTION, juntamente 
com a tabela LOG_EXECUCAO, para que grave exceções inesperadas.*/

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