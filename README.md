# terraform-provider-sdm-examples
This is the examples repository for the [strongDM Terraform Provider](https://github.com/strongdm/terraform-provider-sdm).

---
> **NOTE:**  
> To increase flexibility when managing a large volume of Resources, Role Grants have
been deprecated in favor of Access Rules, which allow you to grant access based
on Resource tags and type.
>
> Previously, you would grant a Role access to specific Resources by ID via Role
Grants. Now, when using Access Rules, the best practice is to give Roles access to Resources based on type and tags.
>
>The following examples demonstrate Dynamic Access Rules with tags and Resource types, as well as Static Access Rules. If it is _necessary_ to grant access to specific Resources in the same way as Role Grants did, you can use Resource IDs directly in Access Rules.
---
