# MD_Project
Machine Discovery Final Project: No free Source Matrix

## Overview
This repository is a duplication of the final team project of NTU Machine Discovery in Fall, 2016. ([website](http://www.csie.ntu.edu.tw/~sdlin/Courses/MD.html)) This project is worked by Zong-Xing Lin, Chiu-Te Wang, and Chih-Te Lai. The objective of the project is to design a cross-domain recommendation system which is trained in an active learning framework with limit querying budgets. In this project, we try different querying strategies and models of transfer collaborative filtering, and give a brief discussion on the performance and transferability in the results. We use the dataset which is provided in the courses and is consisted of ratings in two domains, a source domain and a target domain. Ratings in both domains are sparse, and the number of ratings in target domain is much fewer than that in source domain.

## Reference
the idea of the project is based on several works, including:  
1. the orthogonal nonegative tri-factorization model from the [work](http://dl.acm.org/citation.cfm?id=1150420) of Chris Ding, Tao Li, Wei Peng, Haesun Park @ACM 2006  
2. the mapping model from the [work](http://dl.acm.org/citation.cfm?id=2623657) of Chung-Yi Li, and Shou-De Lin @ACM 2014  
3. the codebook model from the [work](http://dl.acm.org/citation.cfm?id=1661773) of Bin Li, Qiang Yang, and Xiangyang Xue @ACM 2014  
4. the transfer probabilistic model from the [work](http://ieeexplore.ieee.org/document/7023342/) of How Jing, An-Chun Liang, Shou-De Lin, and Yu Tsao @IEEE 2014