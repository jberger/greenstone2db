import os
from xml.dom import minidom

allSql = ''

for root, dirs, files in os.walk('C:\\Users\\Phil\\Desktop\\exported_GreenstoneMETS'):
	for name in files:

		dcTitle = ''
		dcCreator = ''
		dcSubject = ''
		dcDescription = ''
		dcPublisher = ''
		dcContributor = ''
		dcDate = ''
		dcType = ''
		dcFormat = ''
		dcIdentifier = ''
		dcSource = ''
		dcLanguage = ''
		dcRelation = ''
		dcCoverage = ''
		dcRights = ''
		
		if name == 'docmets.xml':
			myDom = minidom.parse(os.path.join(root,name))
			myElements = myDom.getElementsByTagName('gsdl3:Metadata')
			for element in myElements:
				if element.attributes['name'].value == 'dc.Title':
					dcTitle = dcTitle + ', ' + element.firstChild.data
				if element.attributes['name'].value == 'dc.Creator':
					dcCreator = dcCreator + ', ' + element.firstChild.data
				if element.attributes['name'].value == 'dc.Subject':
					dcSubject = dcSubject + ', ' + element.firstChild.data
				if element.attributes['name'].value == 'dc.Description':
					dcDescription = dcDescription + ', ' + element.firstChild.data
				if element.attributes['name'].value == 'dc.Publisher':
					dcPublisher = dcPublisher + ', ' + element.firstChild.data
				if element.attributes['name'].value == 'dc.Contributor':
					dcContributor = dcContributor + ', ' + element.firstChild.data
				if element.attributes['name'].value == 'dc.Date':
					dcDate = dcDate + ', ' + element.firstChild.data
				if element.attributes['name'].value == 'dc.Type':
					dcType = dcType + ', ' + element.firstChild.data
				if element.attributes['name'].value == 'dc.Format':
					dcFormat = dcFormat + ', ' + element.firstChild.data
				if element.attributes['name'].value == 'dc.Identifier':
					dcIdentifier = dcIdentifier + ', ' + element.firstChild.data
				if element.attributes['name'].value == 'dc.Source':
					dcSource = dcSource + ', ' + element.firstChild.data
				if element.attributes['name'].value == 'dc.Language':
					dcLanguage = dcLanguage + ', ' + element.firstChild.data
				if element.attributes['name'].value == 'dc.Relation':
					dcRelation = dcRelation + ', ' + element.firstChild.data
				if element.attributes['name'].value == 'dc.Coverage':
					dcCoverage = dcCoverage + ', ' + element.firstChild.data
				if element.attributes['name'].value == 'dc.Rights':
					dcRights = dcRights + ', ' + element.firstChild.data

			sqlChunk = "(" + "'" + dcTitle[2:] + "', " + "'" + dcCreator[2:] + "', " + "'" + dcSubject[2:] + "', " + "'" + dcDescription[2:] + "', " + "'" + dcPublisher[2:] + "', " + "'" + dcContributor[2:] + "', " + "'" + dcDate[2:] + "', " + "'" + dcType[2:] + "', " + "'" + dcFormat[2:] + "', " + "'" + dcIdentifier[2:] + "', " + "'" + dcSource[2:] + "', " + "'" + dcLanguage[2:] + "', " + "'" + dcRelation[2:] + "', " + "'" + dcCoverage[2:] + "', " + "'" + dcRights[2:] + "')" 
			allSql = allSql + ", " + sqlChunk

completeSql = "INSERT INTO dcRecords VALUES" + allSql[2:] + ";"

print(completeSql)

