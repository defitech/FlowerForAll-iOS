##Local
genstrings -o en.lproj Classes/*.m Classes/*/*.m Classes/*/*/*.m 


app_dir="./Apps"
x=$(find $app_dir/* -maxdepth 0 -type d)
for app_path in $x
do 
	app=${app_path##$app_dir/}
	genstrings -o $app_path/en.lproj $app_path/*.m $app_path/*/*.m 
done