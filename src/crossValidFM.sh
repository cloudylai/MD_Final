if [ $# -ne 3 ]; then
	echo $0: Usage: crossValid.sh [train file path] [iter] [dir]
	exit 1
fi

mkdir $3

python pickCrossValidation.py $1 "$3"/outTrain.txt "$3"/outValid.txt 5
cd libfm-1.42.src/

echo "doing cross validation..."

for ((round=0; round<=4; round++))
do
echo "$round validation"

./scripts/triple_format_to_libfm.pl -in ../"$3"/outTrain.txt"$round",../"$3"/outValid.txt"$round" -target 2 -separator "\t" >> ../"$3"/nnn
./bin/libFM -task r -train ../"$3"/outTrain.txt"$round".libfm --test ../"$3"/outValid.txt"$round".libfm -dim "1,1,8" -init_stdev 0.001 -iter $2 >> ../"$3"/result.txt
done

cd ..
python readCrossValid.py "$3"/result.txt $2

rm -rf "$3"


