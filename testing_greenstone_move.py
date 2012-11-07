import os
from xml.dom import minidom

allSql = ''

for root, dirs, files in os.walk('.'):
	for name in files:

		if name != 'docmets.xml':
			continue

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
		
		myDom = minidom.parse(os.path.join(root,name))
		myElements = myDom.getElementsByTagName('gsdl3:Metadata')
		for element in myElements:
			value = element.attributes['name'].value
			if value == 'dc.Title':
				dcTitle += ', ' + element.firstChild.data
			if value == 'dc.Creator':
				dcCreator += ', ' + element.firstChild.data
			if value == 'dc.Subject':
				dcSubject += ', ' + element.firstChild.data
			if value == 'dc.Description':
				dcDescription += ', ' + element.firstChild.data
			if value == 'dc.Publisher':
				dcPublisher += ', ' + element.firstChild.data
			if value == 'dc.Contributor':
				dcContributor += ', ' + element.firstChild.data
			if value == 'dc.Date':
				dcDate += ', ' + element.firstChild.data
			if value == 'dc.Type':
				dcType += ', ' + element.firstChild.data
			if value == 'dc.Format':
				dcFormat += ', ' + element.firstChild.data
			if value == 'dc.Identifier':
				dcIdentifier += ', ' + element.firstChild.data
			if value == 'dc.Source':
				dcSource += ', ' + element.firstChild.data
			if value == 'dc.Language':
				dcLanguage += ', ' + element.firstChild.data
			if value == 'dc.Relation':
				dcRelation += ', ' + element.firstChild.data
			if value == 'dc.Coverage':
				dcCoverage += ', ' + element.firstChild.data
			if value == 'dc.Rights':
				dcRights += ', ' + element.firstChild.data

		sqlChunk = "(" + "'" + dcTitle[2:] + "', " + "'" + dcCreator[2:] + "', " + "'" + dcSubject[2:] + "', " + "'" + dcDescription[2:] + "', " + "'" + dcPublisher[2:] + "', " + "'" + dcContributor[2:] + "', " + "'" + dcDate[2:] + "', " + "'" + dcType[2:] + "', " + "'" + dcFormat[2:] + "', " + "'" + dcIdentifier[2:] + "', " + "'" + dcSource[2:] + "', " + "'" + dcLanguage[2:] + "', " + "'" + dcRelation[2:] + "', " + "'" + dcCoverage[2:] + "', " + "'" + dcRights[2:] + "')" 
		allSql += ", " + sqlChunk

completeSql = "INSERT INTO dcRecords VALUES" + allSql[2:] + ";"

print(completeSql)

