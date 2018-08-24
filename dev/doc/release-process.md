# Release process #

## As soon as the previous version branched off master ##

- [ ] Create a new issue to track the release process where you can copy-paste
  the present checklist.
- [ ] Change the version name to the next major version and the magic numbers
  (see [#7008](https://github.com/coq/coq/pull/7008/files)).
- [ ] Put the corresponding alpha tag using `git tag -s`.
  The `VX.X+alpha` tag marks the first commit to be in `master` and not in the
  branch of the previous version.
- [ ] Create the `X.X+beta1` milestone if it did not already exist.
- [ ] Decide the release calendar with the team (freeze date, beta date, final
  release date) and put this information in the milestone (using the
  description and due date fields).

## About one month before the beta ##

- [ ] Create the `X.X.0` milestone and set its due date.
- [ ] Send an announcement of the upcoming freeze on Coqdev and ask people to
  remove from the beta milestone what they already know won't be ready on time
  (possibly postponing to the `X.X.0` milestone for minor bug fixes,
  infrastructure and documentation updates).
- [ ] Determine which issues should / must be fixed before the beta, add them
  to the beta milestone, possibly with a
  ["priority: blocker"](https://github.com/coq/coq/labels/priority%3A%20blocker)
  label. Make sure that all these issues are assigned (and that the assignee
  provides an ETA).
- [ ] Ping the development coordinator (**@mattam82**) to get him started on
  the update to the Credits chapter of the reference manual.
  See also [#7058](https://github.com/coq/coq/issues/7058).
  The command to get the list of contributors for this version is
  `git shortlog -s -n VX.X+alpha..master | cut -f2 | sort -k 2`
  (the ordering is approximative as it will misplace people with middle names).

## On the date of the feature freeze ##

- [ ] Create the new version branch `vX.X` and
  [protect it](https://github.com/coq/coq/settings/branches)
  (activate the "Protect this branch", "Require pull request reviews before
  merging" and "Restrict who can push to this branch" guards).
- [ ] Remove all remaining unmerged feature PRs from the beta milestone.
- [ ] Start a new project to track PR backporting. The proposed model is to
  have a "X.X-only PRs" column for the rare PRs on the stable branch, a
  "Request X.X inclusion" column for the PRs that were merged in `master` that
  are to be considered for backporting, a "Waiting for CI" column to put the
  PRs in the process of being backported, and "Shipped in ..." columns to put
  what was backported. (The release manager is the person responsible for
  merging PRs that target the version branch and backporting appropriate PRs
  that are merged into `master`).
  A message to **@coqbot** in the milestone description tells it to
  automatically add merged PRs to the "Request X.X inclusion" column.
- [ ] Delay non-blocking issues to the appropriate milestone and ensure
  blocking issues are solved. If required to solve some blocking issues,
  it is possible to revert some feature PRs in the version branch only.

## Before the beta release date ##

- [ ] Ensure the Credits chapter has been updated.
- [ ] Ensure an empty `CompatXX.v` file has been created.
- [ ] Ensure that an appropriate version of the plugins we will distribute with
  Coq has been tagged.
- [ ] Have some people test the recently auto-generated Windows and MacOS
  packages.
- [ ] Change the version name from alpha to beta1 (see
  [#7009](https://github.com/coq/coq/pull/7009/files)).
  We generally do not update the magic numbers at this point.
- [ ] Put the `VX.X+beta1` tag using `git tag -s`.

### These steps are the same for all releases (beta, final, patch-level) ###

- [ ] Send an e-mail on Coqdev announcing that the tag has been put so that
  package managers can start preparing package updates.
- [ ] Draft a release on GitHub.
- [ ] Get **@maximedenes** to sign the Windows and MacOS packages and
  upload them on GitHub.
- [ ] Prepare a page of news on the website with the link to the GitHub release
  (see [coq/www#63](https://github.com/coq/www/pull/63)).
- [ ] Upload the new version of the reference manual to the website.
  *TODO: setup some continuous deployment for this.*
- [ ] Merge the website update, publish the release
  and send annoucement e-mails.
- [ ] Ping **@Zimmi48** to publish a new version on Zenodo.
  *TODO: automate this.*
- [ ] Close the milestone

## At the final release time ##

- [ ] Change the version name to X.X.0 and the magic numbers (see
  [#7271](https://github.com/coq/coq/pull/7271/files)).
- [ ] Put the `VX.X.0` tag.

Repeat the generic process documented above for all releases.

- [ ] Switch the default version of the reference manual on the website.

## At the patch-level release time ##

We generally do not update the magic numbers at this point (see
[`2881a18`](https://github.com/coq/coq/commit/2881a18)).

## Note for the OPAM package maintainers ##

In addition to updating the OPAM package, the using instructions at
<https://coq.inria.fr/opam/www/using.html> must be updated.
To do so, edit the `COQV` and `OCAMLV` variables at
<https://github.com/coq/opam-coq-archive/blob/master/Makefile>.
