# Smart Proxy - ACD

This plug-in adds support for [Application Centric Deployment](https://github.com/ATIX-AG/foreman_acd) to Foreman's Smart Proxy.

## Features

- Download the ansible playbook to run
- Run the ansible playbook on the smart proxy
- The ansible playbook will send the report back to foreman

## Installation (in development)

### Prerequisites

We expect your proxy to also have
[smart_proxy_dynflow](https://github.com/theforeman/smart_proxy_dynflow)
and [foreman-tasks-core](https://github.com/theforeman/foreman-tasks) as
a gem requirement.

### Get the code

**Smart proxy part**

Clone the repository:

```
git clone git@github.com:ATIX-AG/smart_proxy_acd.git
```

Point the foreman proxy to use this plugin with this line in proxy's `bundler.d/Gemfile.local.rb`
assuming the smart proxy and `smart_proxy_acd` share the same parent directory.

```
gem 'smart_proxy_acd', :path => '../smart_proxy_acd'
```

Enable the plugin in proxy's `config/settings.d/acd.yml`:

```
---
:enabled: true
```

**Foreman part**

Refer to [foreman_acd](https://github.com/ATIX-AG/foreman_acd) instructions.

### Check it's working

After the proxy are up and running, reload the proxy features on Foreman (Infrastructure > Smart Proxies)
and the ACD feature should appear as a new one.

At this point, you should be able to run an ansible playbook of a application instance configured by
application centric deployment.
You should be able to see the output of these jobs under 'Monitor > Jobs' in Foreman.
