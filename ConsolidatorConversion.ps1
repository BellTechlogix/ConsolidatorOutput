<#
	ConsolidatorConversion.ps1
	Created By - Kristopher Roy
	Created On - Aug 10 2021
	Modified On - 

	This Script grabs the output of consolidator moves the fields around for Kingland input and sets them to lowercase
#>

#variables
$path = 'C:\projects\gtil\'
$filename = 'consolidator.csv'
#FTPVariables
$username = "test"
$password = "123qwe"
$local_file = $path$filename
$remote_file = "ftp://192.168.2.222/PROD_HR.Import.csv"
 
#grab the csv swap the UserID and Email fields and then make both lowercase
$ConslidatorUsers = import-csv $path$filename|select BusUnit,ComplianceRegion,DefaultPassword,Dept,Effective_Date,@{N='UserID';E={$_.UserID.ToLower()}},Employee_ID,FirstName,HireDate,JobCode,Title,LastName,MiddleName,TaxID,Status,SupervisorID,@{N='EmailAddress';E={$_.EmailAddress.ToLower()}},LocationDesc,LocationPhone,LocationCity,LocationState,LocationZip,LocationCode,SEC_Role,ID_Check,Supports_User_Rename,Supports_User_Reopen,Monitored,UnMonitored,DefaultCountry,Date_Format

#export the csv back to the same location
$ConslidatorUsers|export-csv $path$filename -NoTypeInformation

#upload file to ftp
$ftprequest = [System.Net.FtpWebRequest]::Create("$remote_file")
$ftprequest = [System.Net.FtpWebRequest]$ftprequest
$ftprequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
$ftprequest.Credentials = new-object System.Net.NetworkCredential($username, $password)
$ftprequest.UseBinary = $true
$ftprequest.UsePassive = $true
$filecontent = gc -en byte $local_file
$ftprequest.ContentLength = $filecontent.Length
$run = $ftprequest.GetRequestStream()
$run.Write($filecontent, 0, $filecontent.Length)
$run.Close()
$run.Dispose()
