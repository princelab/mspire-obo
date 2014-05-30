# Mspire::Obo

Tools for working with ontologies (specificially obo files) with built-in
access to mass spectrometry related ontologies.

## Installation

    gem install mspire-obo

## Examples

```ruby
require 'mspire/obo'
```

### Discover which ontologies are available

```ruby
Mspire::Obo.available  # =>

[{:full_name=>"protein modification ontology",
  :uri=> "http://psidev.cvs.sourceforge.net/viewvc/psidev/psi/mod/data/PSI-MOD.obo",
  :namespace=>"MOD",
  :path=>"/home/jtprince/dev/mspire-obo/obo/PSI-MOD.obo",
  :version=>"1.013.0",
  :key=>:mod},
 {:full_name=>"Imaging MS Ontology",
 ...
]

```

### Use a particular ontology

Keywords (downcased symbol of the namespace) are used to easily load an ontology.

```ruby
ontologies_by_key = Mspire::Obo.available(:key)  # => index the available obos by their key

ms_obo = Mspire::Obo[:ms] # the Proteomics Standards Initiative Mass Spectrometry Ontology
```

### Access ontology information

Can create hashes on the fly.

```ruby
id_to_name_hash = ms_obo.make_id_to_name
id_to_name_hash['MS:1000005'] # => 'sample volume'

id_to_stanza_hash = ms_obo.make_id_to_stanza
...
```

Can make and set hashes (bake them into the Obo object)

```ruby
ms_obo.id_to_name!
ms_obo.id_to_name['MS:1000005'] # => 'sample volume'
```

If you want all hashes baked in:

```ruby
ms_obo.make_all!
```

### Cast values

```ruby
ms_obo.id_to_cast!
ms_obo.cast('MS:1000004') # => :to_f
ms_obo.cast('MS:1000004', '3.3') # => 3.3 (a Float)
```

### Access ontology meta-information

```ruby
ms_obo.version
ms_obo.full_name
ms_obo.uri
...
```

### Multiple ontologies? - create merged lookup hashes 

```ruby
group = Mspire::Obo::Group.new [Mspire::Obo[:ms], Mspire::Obo[:uo]]
a_hash = group.make_id_to_stanza # if you want the hash itself
group.id_to_stanza!
group.id_to_stanza["UO:0000012"] => an Obo::Stanza object
group.id_to_stanza["IMS:1001207"] => an Obo::Stanza object
```

### Use *any* obo file

```ruby
obo = Mspire::Obo.new("somefile.obo")
```
