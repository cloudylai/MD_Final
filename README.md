# MD_Final
Machine Discovery Final Project: No free Source Matrix

## Introduction
This repository is a duplication of the final team project of NTU Machine Discovery in Fall, 2016. ([website](http://www.csie.ntu.edu.tw/~sdlin/Courses/MD.htm)) This project is worked by Zong-Xing Lin, Chiu-Te Wang, and Chih-Te Lai. The objective of the project is to design a cross-domain recommendation system which is trained in an active learning framework with limit querying budgets. In this project, we try different querying strategies and models of transfer collaborative filtering. A diagram of our learning framework is below. We attempt to build recommendation system on target matrix, and we aslo want to obtain and transfer the information from source matrix with limit querying. A final report about the performance and transferability is provided in the results/ directory. We use the dataset which is provided in the courses and is consisted of ratings in two domains, a source domain and a target domain. Ratings in both domains are sparse, and the number of ratings in target domain is equal to that in source domain.(source rating: 1650387, target rating: 1650387)

![image1](https://github.com/cloudylai/MD_Final/blob/master/images/diagram_1.png)  

## Method
We apply three models to this problem. The three models: (1) matching matrix method [2], (2) codebook method [3], (3) transfer probability collective factorization model (TPCF) [4]. The mathematical descriptions of these three models are in report and a brief explanation of these models is the following. The idea behind matching matrix method is to map the users and items between the source domain and the target domain. The key assumption of codebook method is that the similar latent features can be extracted from the source and target domains and that a matrix (codebook) is used to transfer the latent features from the source to the target domain. TPCF is a probabilistic model in which the source and the target domain contain partial shared users and items, and TPCF can be trained by jointly utilizing the data from both the source and the target domain. Based on these settings, we train our models by actively querying data with different strategies.  


## Result
We use different active query methods on our models. For codebook method, we try active query on: (1) low density user-item cluster, (2) low density item cluster, (3) small size item cluster. The following is the testing RMSE of codebook method among above three query strategies and a baseline (random). This figure shows that our three strategies generally outperform the baseline when we have enough number of query budgets (more than 100).

![image2](https://github.com/cloudylai/MD_Final/blob/master/results/active_query_table_1.png)  


## Reference
the idea of the project is based on several works, including:  
1. the orthogonal nonegative tri-factorization model from the [work](http://dl.acm.org/citation.cfm?id=1150420) of Chris Ding, Tao Li, Wei Peng, Haesun Park @ACM 2006  
2. the mapping model from the [work](http://dl.acm.org/citation.cfm?id=2623657) of Chung-Yi Li, and Shou-De Lin @ACM 2014  
3. the codebook model from the [work](http://dl.acm.org/citation.cfm?id=1661773) of Bin Li, Qiang Yang, and Xiangyang Xue @ACM 2014  
4. the transfer probabilistic model from the [work](http://ieeexplore.ieee.org/document/7023342/) of How Jing, An-Chun Liang, Shou-De Lin, and Yu Tsao @IEEE 2014