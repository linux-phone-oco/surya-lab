<!-- Generated from data/ by tad. Do not edit by hand. -->

# Upstreams

<a id="idealkb"></a>
### ideal-knowledge-base (idealkb)

Kind
: kb-instance

Address
: https://github.com/grenudi/ideal-knowledge-base

How
: A pull request to the repository with the change to the generic file; a base that changed a generic file sees it as the diff follow.sh reports (exit 3) - send that diff. Record it here as an upstream item (ikb upstream-item --upstream idealkb --form patch --file auto).

Contacts
: grenudi (owner); the ikb session

Notes
: Where the standing tables, the generic queries and records, ikb and install-ikb.sh come from; the pin is idealkb.toml.


<a id="device-template"></a>
### device-template

Kind
: kb-instance

Address
: https://github.com/linux-phone-oco/device-template

How
: A pull request to the template with what every device would need (a part of the parts contract, a phone query, a test-run change); a finding about the template is an upstream item of form information.

Contacts
: linux-phone-oco orchestration

Notes
: Where this base's device layer comes from: the parts contract (devicebase.toml), the phone queries, the records part, device, backlog-status, backlog-needs and test-run.
