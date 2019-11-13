## Component Importer CI:

The config.yml should contain 2 workflows:

### Component Importer Scheduled Job

This job is needed so the Framer package is autonomously updated whenever the component library itself changes. We do this using a scheduled hourly/daily/weekly job which determines dependency updates based on pre-configured package names using the yarn-pkg-version-diff CLI. If dependencies have been updated, it will import the components on a feature branch and generate a PR using the Hub Orb. The commit message/PR messages can be very simple for now, but we should consider adding a command to the yarn-pkg-version-diff CLI that generates a pretty PR message similar to that of dependabot. We can also consider moving this utility into the Framer Bridge CLI although I think that's for another day.

### Master Commit

For each master commit, we should invoke the Framer Bridge CLI and perform a build and publish to the Framer Store. This will trigger every time someone makes a commit to the repository to fix props in imported components and everytime a PR from the component importer scheduled job is merged.
All of this configuration should be eventually be published in a Framer Bridge Orb. For each Framer CLI flow (e.g. build and publish) we should have an orb job, allowing other jobs as part of the orb to easily call each other.
Let's first test with the carbon-design-system.framerfx repo with having all of the CLI logic inline within the CircleCI config, when we have the flow down let's port all of the logic to the orb and bake it into the framer-bridge-starter-kit as well as the carbon-design-system.framerfx repos.
