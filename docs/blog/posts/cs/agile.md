---
title: Agile software development
authors:
  - xman
date:
    created: 2023-11-05T10:00:00
categories:
    - CS
comments: true
---

[Agile software development](https://en.wikipedia.org/wiki/Agile_software_development) is an umbrella term for approaches to developing software that reflect the values and principles agreed upon by The Agile Alliance, a group of 17 software practitioners in 2001.

<!-- more -->

The practitioners cite inspiration from new practices at the time including [extreme programming](https://en.wikipedia.org/wiki/Extreme_programming), [scrum](https://en.wikipedia.org/wiki/Scrum_\(software_development\)), dynamic systems development method, adaptive software development and being sympathetic to the need for an alternative to documentation driven, heavyweight software development processes.

Many software development practices emerged from the agile mindset. These agile-based practices, sometimes called `Agile` (with a capital A) include requirements, discovery and solutions improvement through the collaborative effort of self-organizing and cross-functional teams with their customer(s)/end user(s).

While there is much anecdotal evidence that the agile mindset and agile-based practices improve the software development process, the empirical evidence is limited and less than conclusive.

## Values and Principles

### Values

The agile manifesto reads:

We are uncovering better ways of developing software by doing it and helping others do it. Through this work we have come to value:

- **Individuals and interactions** over processes and tools
- **Working software** over comprehensive documentation
- **Customer collaboration** over contract negotiation
- **Responding to change** over following a plan

That is, while there is value in the items on the right, we value the items on the left more.

Scott Ambler explained:

- Tools and processes are important, but it is more important to have competent people working together effectively.
- Good documentation is useful in helping people to understand how the software is built and how to use it, but the main point of development is to create software, not documentation.
- A contract is important but is no substitute for working closely with customers to discover what they need.
- A project plan is important, but it must not be too rigid to accommodate changes in technology or the environment, stakeholders' priorities, and people's understanding of the problem and its solution.

Introducing the manifesto on behalf of the Agile Alliance, Jim Highsmith said,

> The Agile movement is not anti-methodology, in fact many of us want to restore credibility to the word methodology. We want to restore a balance. We embrace modeling, but not in order to file some diagram in a dusty corporate repository. We embrace documentation, but not hundreds of pages of never-maintained and rarely-used tomes. We plan, but recognize the limits of planning in a turbulent environment. Those who would brand proponents of XP or SCRUM or any of the other Agile Methodologies as "hackers" are ignorant of both the methodologies and the original definition of the term hacker.

### Principles

The values are based on these principles:

1. Customer satisfaction by early and continuous delivery of valuable software.
2. Welcome changing requirements, even in late development.
3. Deliver working software frequently (weeks rather than months).
4. Close, daily cooperation between business people and developers.
5. Projects are built around motivated individuals, who should be trusted.
6. Face-to-face conversation is the best form of communication (co-location).
7. Working software is the primary measure of progress.
8. Sustainable development, able to maintain a constant pace.
9. Continuous attention to technical excellence and good design.
10. Simplicity—the art of maximizing the amount of work not done—is essential.
11. Best architectures, requirements, and designs emerge from self-organizing teams.
12. Regularly, the team reflects on how to become more effective, and adjusts accordingly.

## Overview

### Iterative, incremental, and evolutionary

Most agile development methods **break** product development work into small increments that minimize the amount of up-front planning and design. Iterations, or sprints, are *short* time frames (timeboxes) that typically last from one to four weeks. Each iteration involves a cross-functional team working in all functions: planning, analysis, design, coding, unit testing, and *acceptance* testing. At the end of the iteration a working product is **demonstrated**/showcased to stakeholders. This minimizes overall risk and allows the product to adapt to changes quickly. An iteration might not add enough functionality to warrant a market release, but the goal is to have an available release (with minimal bugs) at the end of each iteration. Through incremental development, products have room to "fail often and early" throughout each iterative phase instead of drastically on a final release date. Multiple iterations might be required to release a product or new features. Working software is the primary measure of progress.

A key advantage of agile approaches is speed to market and risk mitigation. Smaller increments are typically released to market, reducing the time and cost risks of engineering a product that doesn't meet user requirements.

### Efficient and face-to-face communication

The 6th principle of the agile manifesto for software development states "The most efficient and effective method of conveying information to and within a development team is face-to-face conversation". The manifesto, written in 2001 when video conferencing was not widely used, states this in relation to the communication of information, not necessarily that a team should be co-located.

The principle of co-location is that co-workers on the same team should be situated together to better establish the identity as a team and to improve communication. This enables face-to-face interaction, ideally in front of a whiteboard, that reduces the cycle time typically taken when questions and answers are mediated through phone, persistent chat, wiki, or email. With the widespread adoption of remote working during the COVID-19 pandemic and changes to tooling, more studies have been conducted around co-location and distributed working which show that co-location is increasingly less relevant.

No matter which development method is followed, every team should include a *customer representative* (known as product *owner* in Scrum). This representative is agreed by stakeholders to act on their behalf and makes a personal commitment to being available for developers to answer questions throughout the iteration. At the end of each iteration, the project stakeholders together with the customer representative review progress and re-evaluate priorities with a view to optimizing the return on investment (ROI) and ensuring alignment with customer needs and company goals. The importance of stakeholder satisfaction, detailed by frequent interaction and review at the end of each phase, is why the approach is often denoted as a customer-centered methodology.

### Very short feedback loop and adaptation cycle

A common characteristic in agile software development is the daily stand-up (known as daily scrum in the Scrum framework). In a brief session (e.g., 15 minutes), team members **review** collectively how they are progressing toward their goal and agree whether they need to adapt their approach. To keep to the agreed time limit, teams often use simple coded questions (such as what they completed the previous day, what they aim to complete that day, and whether there are any impediments or risks to progress), and delay detailed discussions and problem resolution until after the stand-up.

### Quality focus

Specific tools and techniques, such as continuous integration, automated unit testing, pair programming, test-driven development, design patterns, behavior-driven development, domain-driven design, code refactoring and other techniques are often used to improve quality and enhance product development agility. This is predicated on designing and building quality in from the beginning and being able to demonstrate software for customers at any point, or at least at the end of every iteration.

## Philosophy

Compared to traditional software engineering, agile software development mainly targets complex systems and product development with dynamic, indeterministic and non-linear properties. Accurate estimates, stable plans, and predictions are often hard to get in early stages, and confidence in them is likely to be low. Agile practitioners use their free will to reduce the "leap of faith" that is needed before any evidence of value can be obtained. Requirements and design are held to be emergent. Big up-front specifications would probably cause a lot of waste in such cases, i.e., are not economically sound. These basic arguments and previous industry experiences, learned from years of successes and failures, have helped shape agile development's favor of adaptive, iterative and evolutionary development.

### Adaptive vs. predictive

Development methods exist on a continuum from adaptive to predictive. Agile software development methods lie on the adaptive side of this continuum. One key of adaptive development methods is a rolling wave approach to schedule planning, which identifies milestones but leaves flexibility in the path to reach them, and also allows for the milestones themselves to change.

Adaptive methods focus on adapting quickly to changing realities. When the needs of a project change, an adaptive team changes as well. An adaptive team has difficulty describing exactly what will happen in the future. The further away a date is, the more vague an adaptive method is about what will happen on that date. An adaptive team cannot report exactly what tasks they will do next week, but only which features they plan for next month. When asked about a release six months from now, an adaptive team might be able to report only the mission statement for the release, or a statement of expected value vs. cost.

Predictive methods, in contrast, focus on analysing and planning the future in detail and cater for known risks. In the extremes, a predictive team can report exactly what features and tasks are planned for the entire length of the development process. Predictive methods rely on effective early phase analysis and if this goes very wrong, the project may have difficulty changing direction. Predictive teams often institute a change control board to ensure they consider only the most valuable changes.

Risk analysis can be used to choose between adaptive (agile or value-driven) and predictive (plan-driven) methods.

### Agile vs. waterfall

One of the differences between agile software development methods and waterfall is the approach to quality and testing. In the waterfall model, work moves through software development life cycle (SDLC) phases—with one phase being completed before another can start—hence the testing phase is separate and follows a build phase. In agile software development, however, testing is completed in the same iteration as programming.

Because testing is done in every iteration—which develops a small piece of the software—users can frequently use those new pieces of software and validate the value. After the users know the real value of the updated piece of software, they can make better decisions about the software's future. Having a value retrospective and software re-planning session in each iteration—Scrum typically has iterations of just two weeks—helps the team continuously adapt its plans so as to maximize the value it delivers. This follows a pattern similar to the plan-do-check-act (PDCA) cycle, as the work is planned, done, checked (in the review and retrospective), and any changes agreed are acted upon.

This iterative approach supports a product rather than a project mindset. This provides greater flexibility throughout the development process; whereas on projects the requirements are defined and locked down from the very beginning, making it difficult to change them later. Iterative product development allows the software to evolve in response to changes in business environment or market requirements.

### Code vs. documentation

In a letter to IEEE Computer, Steven Rakitin expressed cynicism about agile software development, calling it "yet another attempt to undermine the discipline of software engineering" and translating "working software over comprehensive documentation" as "we want to spend all our time coding. Remember, real programmers don't write documentation."

This is disputed by proponents of agile software development, who state that developers should write documentation if that is the best way to achieve the relevant goals, but that there are often better ways to achieve those goals than writing static documentation. Scott Ambler states that documentation should be "just barely good enough" (JBGE), that too much or comprehensive documentation would usually cause waste, and developers rarely trust detailed documentation because it's usually out of sync with code, while too little documentation may also cause problems for maintenance, communication, learning and knowledge sharing. Alistair Cockburn wrote of the Crystal Clear method:

> Crystal considers development a series of co-operative games, and intends that the documentation is enough to help the next win at the next game. The work products for Crystal include use cases, risk list, iteration plan, core domain models, and design notes to inform on choices...however there are no templates for these documents and descriptions are necessarily vague, but the objective is clear, just enough documentation for the next game. I always tend to characterize this to my team as: what would you want to know if you joined the team tomorrow.