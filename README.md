# MySql-Dumb-Backup

This small script does one simple thing: Creates a "dumb" backup of "smart" MySQL databases. Meaning the product has all your same great data with:
- No auto-increment unique keys (those are copied as just plain INTs)
- No Foreign Key constraints
- No Unique Keys
- No Stored Procedures
- No Triggers

Then you can easily export / dump that version and upload somewhere else for people do all sorts of READ ONLY number crunching and data analysis.

# Usage

Copy in to your MySQL editor of choice (like Workbench), change the names of the in and out (master backup) databases, and run the puppy.
