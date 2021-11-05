## How 
1. **Get your QualComm partition_la.xml from git, it should be located at "qcom/es17/Test_Device/common/config/8155 or 6155/ufs/partition_la.xml"**
2. **java -jar ../tool/saxon-he-10.6.jar -s:partition_la_example.xml -xsl:partition_to_csv.xsl -o:partition_la_example.csv**

