func1 () {
var1="sdf"
}

func2 () {
var2=$1
}

func1
echo "var1 is" $var1
func2 $var1

echo $var2