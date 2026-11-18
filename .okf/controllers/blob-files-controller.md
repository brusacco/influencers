---
type: Controller
title: Blob files controller
description: Serves Active Storage blobs from the local storage directory with a one-year public cache header.
tags: [media, security, caching]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T13:00:00Z
sources:
  - id: blob-files-controller
    title: BlobFilesController
    resource: ../../app/controllers/blob_files_controller.rb
---

# Route and action

`GET /blob_files/:dir1/:dir2/:key` runs `show`. It looks up the Active Storage blob by key and streams the file from disk.[^blob-files-controller]

# Behavior

- The resolved path must stay inside `Rails.root.join('storage')`. Any traversal attempt returns 403.[^blob-files-controller]
- A missing blob or file returns 404.[^blob-files-controller]
- A served file carries `Cache-Control: public, max-age=31536000`.[^blob-files-controller]
