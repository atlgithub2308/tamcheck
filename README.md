# tamcheck
# Module for quick data collection of Quarterly TAM Checks

## Checks currently include

PE Server Name - MB

PE Server Details - MB

PE Server CA Certificate Status - MB

PE Server Infra Status - TL

PE Server Tuning Status

PE Server Module List - TL

PE Server Node Count

PE Server Node Count not expired

PE Server Inactive Node Count

PE Server Node Count using cached catalog

PE Server Node Count without updated catalog


## Checks to add

PE Server hardware info  

## Here is what we are going to do as agreed in our meeting 27/06/24

These checks are to be moved from a single script at https://github.com/coffeeales/tamcheck
and made into individual tasks that can be run via a plan

Ideally this is then able to be run via Bolt or on the PE Server via the console

Output is to be in JSON format

This repo is currently a direct copy of https://github.com/moedes/puppetlabs-pe_quick_data
barring this instruction set

Publishing this needs to be discussed with Tony and Nick prior to pbulish to make sure they are happy with v 1


## Meeting 04/07/24 to determine

Check that everyone has access to the repo

Who will create what tasks?

Code approval?

Branching strategy?


## NOTE: 
  
I haven't done or run a dev/code exercise in 25 years (no real repo tools at the time) so would appreciate any and all ideas/knowledge

================================================================================================= Below is the original owners readme - it is very good so we should try and emulate it

Welcome to your new module. A short overview of the generated parts can be found
in the [PDK documentation][1].

The README template below provides a starting point with details about what
information to include in your README.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with tamcheck](#setup)
    * [What tamcheck affects](#what-tamcheck-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with tamcheck](#beginning-with-tamcheck)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Briefly tell users why they might want to use your module. Explain what your
module does and what kind of problems users can solve with it.

This should be a fairly short description helps the user decide if your module
is what they want.

## Setup

### What tamcheck affects **OPTIONAL**

If it's obvious what your module touches, you can skip this section. For
example, folks can probably figure out that your mysql_instance module affects
their MySQL instances.

If there's more that they should know about, though, this is the place to
mention:

* Files, packages, services, or operations that the module will alter, impact,
  or execute.
* Dependencies that your module automatically installs.
* Warnings or other important notices.

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled,
another module, etc.), mention it here.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you might want to include an additional "Upgrading" section here.

### Beginning with tamcheck

The very basic steps needed for a user to get the module up and running. This
can include setup steps, if necessary, or it can be an example of the most basic
use of the module.

## Usage

Include usage examples for common use cases in the **Usage** section. Show your
users how to use your module to solve problems, and be sure to include code
examples. Include three to five examples of the most important or common tasks a
user can accomplish with your module. Show users how to accomplish more complex
tasks that involve different types, classes, and functions working in tandem.

## Reference

This section is deprecated. Instead, add reference information to your code as
Puppet Strings comments, and then use Strings to generate a REFERENCE.md in your
module. For details on how to add code comments and generate documentation with
Strings, see the [Puppet Strings documentation][2] and [style guide][3].

If you aren't ready to use Strings yet, manually create a REFERENCE.md in the
root of your module directory and list out each of your module's classes,
defined types, facts, functions, Puppet tasks, task plans, and resource types
and providers, along with the parameters for each.

For each element (class, defined type, function, and so on), list:

* The data type, if applicable.
* A description of what the element does.
* Valid values, if the data type doesn't make it obvious.
* Default value, if any.

For example:

```
### `pet::cat`

#### Parameters

##### `meow`

Enables vocalization in your cat. Valid options: 'string'.

Default: 'medium-loud'.
```

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other
warnings.

## Development

In the Development section, tell other users the ground rules for contributing
to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You can also add any additional sections you feel are
necessary or important to include here. Please use the `##` header.

[1]: https://puppet.com/docs/pdk/latest/pdk_generating_modules.html
[2]: https://puppet.com/docs/puppet/latest/puppet_strings.html
[3]: https://puppet.com/docs/puppet/latest/puppet_strings_style.html
