#!/bin/bash
gawk '{if(x == 1){print $0} if($1 =="ItemLatent"){x = 1;} }'
