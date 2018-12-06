# RefEm
Web API for the RefEm application

[ ![Codeship Status for manacitra/refem-api](https://app.codeship.com/projects/9e4be600-db98-0136-acc2-4a98e051cb94/status?branch=master)](https://app.codeship.com/projects/317787)

## Routes
### Root check
`GET/`<br>
Status:
 - 200: API server running (happy)

### Show the paper list
`GET /paper/{searchType}/{keyword}`<br>
Status:
 - 200: paper list returned (happy)
 - 404: paper can not be found by keyword or search type (sad)
 
 ### Show the paper detail
 `GET /paper/{id}`<br>
 Status:
 - 200: paper detail returned (happy)
 - 404: paper detail can not be found by id (sad)
