SET SESSION group_concat_max_len = 1000000;

WITH ochoa AS (SELECT gene,Phosphosite, GROUP_CONCAT(DISTINCT kinase) AS up_stream_och_kinase,COUNT(DISTINCT kinase) AS count_upstream_kinase_och
 FROM phospodb_ochoa_1 GROUP BY gene,Phosphosite ),

 exp_valid AS (SELECT Mapped_Substrate_gene_symbol,psp_phosphosite, GROUP_CONCAT(DISTINCT Mapped_Kinase_Gene_symbol) AS up_stream_exp_kinase,COUNT(DISTINCT Mapped_Kinase_Gene_symbol) AS count_upstream_kinase_exp 
FROM phospodb_exp_valid_kinase_substrate_data GROUP BY Mapped_Substrate_gene_symbol,psp_phosphosite),


 diff_freq AS ( 
SELECT mapped_genesymbol,mapped_phosphosite,COUNT(DISTINCT exp_cond_id) AS freq,
SUM(CASE WHEN expression = 'Up-regulated' THEN 1 ELSE 0 END) AS up_regulated,
SUM(case when expression ='down-regulated' then 1 ELSE 0 END) AS down_regulated,
case when COUNT(DISTINCT exp_cond_id) = (SUM(CASE WHEN expression = 'Up-regulated' THEN 1 ELSE 0 END) + SUM(case when expression ='down-regulated' then 1 ELSE 0 END))
THEN 'True' ELSE 'False'END AS STATUS,
GROUP_CONCAT(DISTINCT CODE SEPARATOR ';') AS exp_code,COUNT(DISTINCT CODE ) AS exp_code_count,
COUNT(DISTINCT CASE WHEN expression = 'Up-regulated' THEN CODE END) AS up_regulated_code_count, 
    COUNT(DISTINCT CASE WHEN expression = 'Down-regulated' THEN CODE END) AS down_regulated_code_count,
GROUP_CONCAT(DISTINCT pmid SEPARATOR ';') AS pmid,COUNT(DISTINCT pmid) AS pmid_count
FROM Updated_final_Differential GROUP BY mapped_genesymbol,mapped_phosphosite),

diff_och AS (SELECT * FROM diff_freq LEFT JOIN ochoa ON diff_freq.mapped_genesymbol = ochoa.gene AND diff_freq.mapped_phosphosite  = ochoa.Phosphosite)

 SELECT * FROM diff_och LEFT JOIN exp_valid ON diff_och.mapped_genesymbol = exp_valid.Mapped_Substrate_gene_symbol AND diff_och.mapped_phosphosite = exp_valid.psp_phosphosite
