json.type          'Authorization'
json.provider      authorization.provider
json.uid           authorization.uid
json.permissions   authorization.permissions
json.info          authorization.provider == 'tssignals' ?
                     authorization.accounts.first :
                     authorization.info
json.created_at    authorization.created_at
json.updated_at    authorization.updated_at
