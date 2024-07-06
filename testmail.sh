curl --url "smtps://sslout.df.eu:465" \
     --ssl-reqd \
     --mail-from "dtrack@maltewildt.de" \
     --mail-rcpt "test@maltewildt.de" \
     --user "dtrack@maltewildt.de:c#Z3uGq4tghx" \
     --upload-file <(echo -e "HAS IST EIN AÖSLDKASÖD k")