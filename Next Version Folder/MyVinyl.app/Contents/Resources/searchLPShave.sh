cd ~/Library/Application\ Support

cat MyVinyl.prefs |
path=$(awk '{
	ct = split ($0, p, "<")
	for (i=1; i<=ct; ++i)
		if (index(p[i], "pathToMyCol") == 1) {
			print substr(p[i], 20)
			exit
		}
	}')

cd "$path"Collection

for i in $(ls | tr " " "~")	#  Fill spaces with ~
do				#  because Unix doesn't like spaces
	file=${i//~/ }		#  Change them back for inputting
	cat "$file"/details.txt |
	tr "\r" "\n" |
	# First get rid of redundant headers
	awk '/<--NAME-->/ {
		++f	# 1 is first.  > 1 is redundant
	}
	/<--TRACKLIST-->/ {
		f = 1
	}
	{
		if (f == 1) print $0
	}' |
	awk -v pattern="$1" -v dir=$i 'BEGIN{
		gsub("~", " ", dir)	#  Change them back for printing
		flg=0
	}
	/<trackTitle>/ {
			#  One line so split it into an array
			split ($0, tunes, "<trackTitle>")
			for (i in tunes) {
				gsub ("</trackTitle>", "", tunes[i])
				#  Look for the pattern
				if (index(tunes[i], pattern))
					#  and print it
					printf ("%s\t%s\n", dir, tunes[i])
			}
	}
	/^<--CRED*/ {	#  Credits sction is where I put artist info
			++flg	# Lines always end in \n now
	}
	{
		if (flg) {	#  Files that use \n
			#  Remove references to CREDITS
			gsub ("<--CREDITS-->", "", $0)
			#  Look for the pattern
			if (index($0, pattern))
				#  and print it
				printf ("%s\t%s\n", dir, $0)
		}
	}
	#  This assumes FORMAT always follows CREDITS
	#  Revise if this ever changes
	/^<--FOR*/ {
		flg = 0
	}'
done 