#!/bin/bash
gawk '{if($1 !="UserLatent"){if($0 == "ItemLatent"){x = 1;} if(x == 0){print $0}}}'
