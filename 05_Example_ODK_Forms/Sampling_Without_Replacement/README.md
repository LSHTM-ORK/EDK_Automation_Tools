#Sampling without replacement in an ODK Xform

Sampling without replacement is a cornerstone in research studies and clinical trials 

The basic requirement for an ODK sampling without replacement process is to select a random sample of n entities from a list p long, without replacement.

i.e. if you had these items in the list

```
A, B, C, D, E, F
```

and you wanted a random sample of 3 items without replacement. then an acceptable sample would be

```
A, D, E
```

or

```
E, F, B
```

but not

```
A, E, A 
```
in which there is replacement of A in the list after A is sampled the first time.


This is a quasi-random solution that uses only the `random()` and `pulldata()` commands that are already built in to ODK. This is pretty sketchy and I would like to see if anyone has a more elegant way to achieve the same end.

First we need to make an external CSV file that contains an array of truly random sequences of numbers which are sampled from a larger set without replacement. In the example below I've sampled 10000 sequences, each with 10 numbers between 1:50 (inclusive), but this could also be sampling of strings or logicals. The larger the number of sequences, the more random the system becomes, but 10000 should be good enough for most real world purposes such as clinical trial randomisations.

The following code (in R) will generate a csv file with the required name_key structure to allow these sequences to be pulled in to odk using `pulldata()` command.

```
#make a data frame with 10,000 rows
	a<-(as.data.frame(1:10000)
#Change the header to name_key
	names(a)<-"name_key"
#create columns to house random samples
	a[,2:11]<-NA
#populate columns with randomly sampled data (here 10 columns, each with a number between 1 and 50 without replacement)
	for(i in 1:nrow(a)){a[i,2:11]<-sample(size = 10,replace = F,x = 1:50)}
#save a CSV file
	write.csv(a,file = "randomer.csv",row.names = F)
```


Then we need an XLSform design to use some of this

type	name	label	calculation
calculate	rnd		once(int(10000*random())+1)
note	note_rnd	The random number is ${rnd}

|Type     |Name         |Label                                              |Calculation|
|---------|-------------|---------------------------------------------------|-----------|
|calculate|randomperson1|                                                   |pulldata('randomer', 'V2', 'name_key', ${rnd})|
|calculate|	randomperson2||		pulldata('randomer', 'V3', 'name_key', ${rnd})
|calculate|	randomperson3	||	pulldata('randomer', 'V4', 'name_key', ${rnd})
|calculate|	randomperson4	||	pulldata('randomer', 'V5', 'name_key', ${rnd})
|calculate|	randomperson5	||	pulldata('randomer', 'V6', 'name_key', ${rnd})
|note|	note_1	|The first person is ${randomperson1||
|note|	note_2	|The first person is ${randomperson2}||
|note|	note_3	|The third person is ${randomperson3}||
|note|	note_4	|The fourth person is ${randomperson4}||
|note|	note_5	|The fifth person is ${randomperson5}||

The rnd variable simply generates a random integer from 1:10000
The pulldata commands on the subsequent lines then use the random number from rnd to access the matching line in the csv file.
Adding more lines here (I called them randomperson1...4 would extend the length of the random sample you get (in the example you could go up to ten, but there's no limit on this)

Convert this xls to xml and load to aggregate with the csv file attached and it should work.


##Example : [https://enketo.lshtm.ac.uk/x/HBxBhmhR](https://enketo.lshtm.ac.uk/x/HBxBhmhR)
