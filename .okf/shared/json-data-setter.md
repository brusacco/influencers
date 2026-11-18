---
type: Concern
title: JSON data setter concern
description: Concern that normalizes the data column to a Hash whether input is a Hash or a JSON string.
tags: [data-payloads]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T12:00:00Z
sources:
  - id: json-data-setter
    title: JsonDataSetter concern
    resource: ../../app/models/concerns/json_data_setter.rb
---

# Overview

`JsonDataSetter` overrides the `data=` setter so the serialized `data` column always receives a Hash.[^json-data-setter]

# Behavior

- A Hash is stored as is.
- A JSON string, as sent by Active Admin forms, is parsed. Blank input becomes `{}`.[^json-data-setter]
- Invalid JSON logs a warning and becomes `{}`. The record is not rejected.[^json-data-setter]
- Any other type becomes `{}`.

# Used by

[TikTok profile](/tiktok/profile.md) and [TikTok post](/tiktok/post.md). The Instagram models do not include it.
