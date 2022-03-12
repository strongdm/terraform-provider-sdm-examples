# Managing Roles

A collection of examples regarding managing Roles.

## Migrating to Access Rules

To increase flexibility when managing a large volume of Resources, Role Grants have
been deprecated in favor of Access Rules, which allow you to grant access based
on Resource tags and type.

The following examples demonstrate the deprecated Role Grants, Dynamic Access
Rules with tags and Resource types, and Static Access Rules.

### Role Grants (deprecated)

Previously, you would grant a Role access to specific Resources by ID via Role
Grants:

```tf
resource "sdm_resource" "redis-test" {
  redis {
    name = "redis-test"
    hostname = "example.com"
    port_override = 4020
    tags = {
      region = "us-west"
      env = "dev"
    }
  }
}

resource "sdm_resource" "postgres-test" {
  postgres {
    name = "postgres-test"
    hostname = "example.com"
    database = "my-db"
    username = "admin"
    password = "hunter2"
    port = 5432
    tags = {
      region = "us-west"
      env = "dev"
    }
  }
}

resource "sdm_role" "engineering" {
  name = "engineering"
}

resource "sdm_role_grant" "engineering-redis" {
  resource_id = sdm_resource.redis-test.id
  role_id = sdm_role.engineering.id
}

resource "sdm_role_grant" "engineering-postgres" {
  resource_id = sdm_resource.postgres-test.id
  role_id = sdm_role.engineering.id
}
```

### Dynamic Access Rules

When using Access Rules, the best practice is to give Roles access to Resources based on
type and tags.

```tf
resource "sdm_role" "engineering" {
  name = "engineering"
  access_rules = jsonencode([

    # Grant access to all dev environment Resources in us-west
    {
      "tags": { "env": "dev", "region": "us-west" }
    },

    # Grant access to all Postgres Resources
    {
      "type": "postgres"
    },

    # Grant access to all Redis Datasources in us-east
    {
      "type": "redis",
      "tags": { "region": "us-east" }
    }
  ])
}
```

### Static Access Rules

If it is _necessary_ to grant access to specific Resources in the same way as
Role Grants did, you can use Resource IDs directly in Access Rules.

```tf
resource "sdm_role" "engineering" {
  name = "engineering"
  access_rules = jsonencode([
    {
      "ids": [
        sdm_resource.redis-test.id,
        sdm_resource.postgres-test.id
      ]
    }
  ])
}
```
