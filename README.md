# moby

## Description

Sometimes when they go fishing, they get a whale and it sinks their boat.

## Installation

### Prerequisites
1. Some version of Ruby.
2. \*nix, so that it has access to /usr/share/dict/words.

### 1. via Homebrew
```shell
$ brew tap thoran/tap
$ brew install thoran/tap/moby
```
### 2. via git
```shell
$ git clone git@github.com:thoran/moby.git
```

## Usage

### From the command line

#### 1. Specify form name and field names
```shell
$ moby --url https://phishing.site --form_name form-name --username_field_name login --password_field_name password
```

#### 2. Specify form name and field names with short switches
This is the same as above, but using alternate switches:

```shell
$ moby --url https://phishing.site --f form-name --user_field login --pass_field password
```

#### 3. Specify form number and field numbers
This selects the second form on the page (using zero-based indexing) and the first and second fields:

```shell
$ moby --url https://phishing.site --form_number 1 --username_field_number 0 --password_field_number 1
```
#### 4. Specify form number and field numbers with short switches
This selects the second form on the page (using zero-based indexing) and the first and second fields:

```shell
$ moby --url https://phishing.site --form_number 1 --user_field_number 0 --pass_field_number 1
```

#### 5. Specify nothing but the URL
```shell
$ moby --url https://phishing.site
```
This is equivalent to:

```shell
$ moby --url https://phishing.site --form_number 0 --username_field_number 0 --password_field_number 1
```

#### 6. With other options
```shell
$ moby --url https://phishing.site --debug --user_agent 'Mozilla/5.0' --username_hostname mydomain.com --username_is_email_address  --verbose
```

Note that `username_hostname` is useful only if `username_is_email_address` is true.

### From within Ruby

#### 1. Specify form name and field names
```ruby
  moby = Moby.new(
    url: 'https://phishing.site',
    form_name: 'form-name',
    username_field_name: 'login',
    password_field_name: 'password'
  )
  moby.counter_phish
```

#### 2. Specify form number and field numbers
This selects the second form on the page (using zero-based indexing) and uses the first and second fields therein:

```ruby
  moby = Moby.new(
    url: 'https://phishing.site',
    form_number: 1,
    username_field_number: 0
    password_field_number: 1,
  )
  moby.counter_phish
```

#### 3. Specify nothing but the URL
```ruby
  moby = Moby.new(
    url: 'https://phishing.site',
  )
  moby.counter_phish
```
This is equivalent to:

```ruby
  moby = Moby.new(
    url: 'https://phishing.site',
    form_number: 0,
    username_field_number: 0
    password_field_number: 1,
  )
  moby.counter_phish
```

#### 4. With other options
```ruby
  moby = Moby.new(
    url: 'https://phishing.site',
    debug: true,
    user_agent: 'Mozilla/5.0',
    username_hostname: 'mydomain.com', # Only useful if username_is_email_address is true.
    username_is_email_address: true,
    verbose: true
  )
  moby.counter_phish
```

Note that there's no equivalent short names for constructor arguments.

## Contributing

1. Fork it: `https://github.com/thoran/moby/fork`
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Create a new pull request
