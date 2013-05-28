# nb: Open the passed argument in netbeans, if it's a project dir the project will open
function nb() { /Applications/Netbeans/Netbeans\ 6.9.app/Contents/MacOS/netbeans --open $1 ;}

# nbrubies: Create an ruby project with the given name in the current directory
function nbrubies() { mkdir nbproject; cd nbproject; echo -en "platform.active=Ruby\nrails.port=3000\nsource.encoding=UTF-8" > project.properties; echo -en "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<project xmlns=\"http://www.netbeans.org/ns/project/1\">\n\t<type>org.netbeans.modules.ruby.railsprojects</type>\n\t<configuration>\n\t\t<data xmlns=\"http://www.netbeans.org/ns/rails-project/1\">\n\t\t\t<name>$1</name>\n\t\t</data>\n\t</configuration>\n</project>" > project.xml ;}

# netbeans: Run the netbeans application from command line
alias netbeans="open /Applications/NetBeans/NetBeans\ 6.9.app/";