---
type: Model
title: Tag model
description: Shared tag vocabulary used by the Instagram profile categorization.
tags: [tagging]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T12:00:00Z
sources:
  - id: tag-model
    title: Tag model
    resource: ../../app/models/tag.rb
  - id: tags-schema
    title: tags and taggings table schema
    resource: ../../db/schema.rb
---

# Overview

`Tag` is the vocabulary behind `acts_as_taggable_on` on [Instagram profiles](/instagram/profile.md). Tag names are unique.[^tags-schema]

# Schema

`tags` stores `name` (unique, case-sensitive binary collation) and `taggings_count`. `taggings` links a tag to any taggable record through `taggable_type` and `taggable_id`.[^tags-schema]

# Behavior

The model only declares which columns Ransack may filter on. It has no custom behavior.[^tag-model]
