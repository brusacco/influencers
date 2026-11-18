---
type: Concern
title: Reach calculator concern
description: Concern estimating unique reach for TikTok profiles from followers and total interactions.
tags: [reach, metrics]
generated:
  by: copilot/claude-haiku-5.5
  at: 2026-11-10T12:00:00Z
sources:
  - id: reach-calculator
    title: ReachCalculator concern
    resource: ../../app/models/concerns/reach_calculator.rb
---

# Overview

`ReachCalculator` estimates unique accounts reached using a hybrid of a follower-based and an interaction-based estimate.[^reach-calculator]

# Formula

- Follower-based reach is `followers * 0.15`, weighted at 0.6.
- Interaction-based reach is `total_interactions * 10`, weighted at 0.4.
- The result is capped at 50% of followers.[^reach-calculator]

# Notes

The [Instagram profile](/instagram/profile.md) model has its own reach formula with different constants and multipliers. The two are not interchangeable.

# Used by

[TikTok profile](/tiktok/profile.md) only.
