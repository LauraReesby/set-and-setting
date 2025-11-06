name: Dev Task
description: Implementation task
title: "[TASK] <title>"
labels: ["task"]
body:
  - type: textarea
    id: summary
    attributes:
      label: Summary
  - type: textarea
    id: steps
    attributes:
      label: Steps
  - type: checkboxes
    id: done
    attributes:
      label: Definition of Done
      options:
        - label: Tests updated/added
        - label: App runs on device
        - label: No new permissions