# Storj DB

**A decentralized JSON database based on Storj network: https://www.storj.io**

## Installation

The package can be installed by adding `storj_db` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:storj_db, "~> 0.0.1"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/storj_db](https://hexdocs.pm/storj_db).


## Storj CLI Installation

You need install Storj Uplink CLI before start.


----------------------------------------------

-- Linux Installation

----------------------------------------------

curl -L https://github.com/storj/storj/releases/latest/download/uplink_linux_amd64.zip -o uplink_linux_amd64.zip

unzip -o uplink_linux_amd64.zip

chmod 755 uplink

sudo mv uplink /usr/local/bin/uplink 


----------------------------------------------

-- Setup

----------------------------------------------

uplink setup


----------------------------------------------

-- Test

----------------------------------------------

- Create a bucket

uplink mb sj://<<bucket-name>>

- Upload a file

uplink cp ~/Desktop/cheesecake.jpg sj://<<bucket-name>>

- List a bucket

uplink ls sj://<<bucket-name>>

- Copy a file

uplink cp sj://<<bucket-name>>/cheesecake.jpg ~/Downloads/cheesecake.jpg

- Copy a link

uplink share --url sj://<<bucket-name>>/cheesecake.jpg