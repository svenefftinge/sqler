// create a macro/endpoint called "_boot",
// this macro is private "used within other macros" 
// because it starts with "_".
_boot {
    // the query we want to execute
    exec = <<SQL
        CREATE TABLE IF NOT EXISTS `users` (
            `ID` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            `name` VARCHAR(30) DEFAULT "@anonymous",
            `email` VARCHAR(30) DEFAULT "@anonymous" 
        );
    SQL
}

// adduser macro/endpoint, just hit `/adduser` with
// a `?user_name=&user_email=` or json `POST` request
// with the same fields.
adduser {
    // what request method will this macro be called
    // default: ["ANY"]
    methods = ["POST"]

    // authorizers,
    // sqler will attempt to send the incoming authorization header
    // to the provided endpoint(s) as `Authorization`,
    // each endpoint MUST return `200 OK` so sqler can continue, other wise,
    // sqler will break the request and return back the client with the error occured.
    // each authorizer has a method and a url, if you ignored the method
    // it will be automatically set to `GET`.
    authorizers = ["GET http://web.hook/api/authorize", "GET http://web.hook/api/allowed?roles=admin,root,super_admin"]

    // the validation rules
    // you can specifiy seprated rules for each request method!
    rules {
        user_name = ["required"]
        user_email =  ["required"]
    }

    // the query to be executed
    exec = <<SQL
        {{ template "_boot" }}

        INSERT INTO users(name, email) VALUES('{{ .Input.user_name | .SQLEscape }}', '{{ .Input.user_email | .SQLEscape }}');
        SELECT * FROM users WHERE id = LAST_INSERT_ID();
    SQL
}

proclist {
    exec = "SHOW PROCESSLIST"
}

tables {
    exec = "SELECT * FROM information_schema.tables"
}

databases {
    exec = "SHOW DATABASES"
}