### Problem Statement
I need a service that will allow user to upload arbitrary data files (primarily csv files) so that the data can be extracted, normalized, and save to a database. This is for a business-to-business service. The website will validate the file format, extract the data, transform it where needed, and load it into a datastore.


### Context
 You are an experienced Rails consultant. You have been contracted to assist me in designing and building this website. Delivery will be complete in 3 steps:

 - Step 1: Define problem for LLM agent to generate a spec.md document that spells our requirements for development.
 - Step 2: Feed spec.md to an LLM agents to generate implementation.md document that breaks down code development of the product into discrete prompts for an LLM agent to execute.
 - Step 3: Feed prompts in implementation.md to LLM agent to systematically generate code to deliver a working product that meets requirements.

 Your task here is to complete step 1 by generating the spec.md document. Before generating the document, feel free to ask me about and clarify any questions necessary to successfully deliver the proposed product. The spec should adhere to the preliminary requirements listed in the next section.


### Requirements
- Website will run on latest stable version of Ruby-on-Rails framework. Website will be generated from scratch.
- Local development environment will be containerized to run locally on Docker.
- User will be able to upload a csv file.
- Website will warn user if there is a validation issue with the file (e.g. inconsistent data formatting or file is duplicate of one already uploaded)
- Website will store contents of valid files that have successfully been upload.
- User will be able to review files they have upload.
- User will be able to download a copy of a file they have previously uploaded.
- Admin will be able to review a list of recent files upload by users.
- Admin will be able to review details of a specific file.
- Admin will be able to review any files uploaded by any user.
- User may only review files that the user has uploaded herself.
- Website functionality will include appropriate unit and integration spec. Tests should be written using rspec framework and adhere to Even Better Specs guidelines: https://evenbetterspecs.github.io/
