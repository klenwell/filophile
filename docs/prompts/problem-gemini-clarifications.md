Answers to points you raised. Where one of your questions is not addressed, use your best judgment.

1. For v1, let's just treat all values as a string. Subsequent versions will introduce data type conversions. The schema should be basic but flexible enough to accommodate different formats uniformly.

2. For v1, inconsistent data formatting means varying number of columns per row. A duplicate file is identified by its contents so a hash should suffice.

3. Let's use postgresql.

4. For auth, let's use oauth. For v1, enable users to log in using their Google account.

5. For v1, make UI simple upload form.

6. No preference on error messaging.

7. No immediate concerns about scalability. Assume largest files may be up to 10k rows.

With this information, please proceed to generate the spec.md document.
