Generate the following models:

**Upload**
- `user_id`: integer (FK)
- `filename`: string
- `content_hash`: string (unique)
- `row_count`: integer
- `column_count`: integer
- `uploaded_at`: datetime
- `original_file`: binary or text (for storing file blob or path)

**UploadRow**
- `upload_id`: integer (FK)
- `row_index`: integer
- `values`: JSON (array of strings)

Add associations:
- `User has_many :uploads`
- `Upload belongs_to :user` and `has_many :upload_rows`
- `UploadRow belongs_to :upload`

Add model validations and database constraints. Write full model specs.
