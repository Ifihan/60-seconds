"use client";

import Link from "next/link";
import Nav from "@/components/Nav/Nav";
import styles from "./page.module.css";

export default function AboutPage() {
  return (
    <>
      <Nav />
      <main className={styles.page}>
        <article className={styles.article}>

          {/* Hero */}
          <header className={styles.hero}>
            <h1 className={styles.title}>60 Seconds.</h1>
            <p className={styles.subtitle}>
              Pick a topic. Prep for five minutes. Speak for one.
            </p>
            <p className={styles.lead}>
              A daily practice for people who want to think and talk more clearly.
            </p>
          </header>

          {/* What It Is */}
          <section className={styles.section}>
            <h2 className={styles.h2}>What It Is</h2>
            <p>
              60 Seconds is a simple tool built around one habit. Every day, you pick a random
              topic from your field, something you're learning, or anything you're curious about.
              You prep your thoughts for five minutes, then speak on it for sixty seconds.
            </p>
          </section>

          {/* Why It Works */}
          <section className={styles.section}>
            <h2 className={styles.h2}>Why It Works</h2>
            <p>
              Speaking clearly on a topic, without preparation time to hide behind, is one of
              the most honest signals of whether you actually understand it.
            </p>
            <p>
              Most of us have a gap between what we know and what we can articulate under pressure.
              We read the paper, follow the thread, nod along in the meeting. But asked to explain
              it cold, in one minute, clearly? That's a different skill.
            </p>
          </section>

          {/* The Science */}
          <section className={styles.section}>
            <h2 className={styles.h2}>The Science Behind It</h2>
            <p>This isn't just intuitive. Several areas of research support why this kind of practice works.</p>

            <div className={styles.scienceBlock}>
              <h3 className={styles.h3}>1. Deliberate practice</h3>
              <p>
                In 1993, psychologist Anders Ericsson and colleagues published what became one of
                the most cited frameworks in skill development: deliberate practice. The core idea
                is that improvement doesn't come from doing something over and over. It comes from
                structured, goal-directed practice with a specific focus on closing the gap between
                where you are and where you want to be.
              </p>
              <p>
                Ericsson defined deliberate practice as activities "specially designed to improve
                the current level of performance through repetition and successive refinement."
              </p>
              <p>
                Explaining a technical topic clearly, to yourself, in a constrained time window,
                is exactly this. You're not rehearsing a script. You're repeatedly stress-testing
                your understanding against the pressure of having to produce clear speech. And you
                notice, every time, exactly where it breaks down.
              </p>
              <p className={styles.ref}>
                Ericsson, K. A., Krampe, R. T., &amp; Tesch-Römer, C. (1993). The role of
                deliberate practice in the acquisition of expert performance.{" "}
                <em>Psychological Review, 100</em>(3), 363–406.
              </p>
            </div>

            <div className={styles.scienceBlock}>
              <h3 className={styles.h3}>2. Retrieval practice</h3>
              <p>
                There's a well-documented effect in cognitive science called the testing effect
                (or retrieval practice effect): actively recalling information improves retention
                significantly more than passively reviewing it.
              </p>
              <p>
                Research by Roediger, Karpicke, and others has consistently shown that retrieval
                practice outperforms re-reading, note-taking, and even concept mapping for
                long-term retention. A 2006 study found that students who practised retrieval
                retained significantly more material a week later than those who restudied the
                same content.
              </p>
              <p>
                More relevant to 60 Seconds: research on "learning by teaching" suggests that
                the act of explaining, generating instructional speech about a topic, triggers
                the same retrieval mechanisms and produces similar learning benefits. You can't
                explain what you can't recall. The act of trying forces your brain to find and
                reconstruct what it knows, strengthening those connections in the process.
              </p>
              <p className={styles.ref}>
                Roediger, H. L., &amp; Karpicke, J. D. (2006). Test-enhanced learning: Taking
                memory tests improves long-term retention. <em>Psychological Science, 17</em>(3),
                249–255.
                <br />
                Kobayashi, K. (2022). The retrieval practice hypothesis in research on learning
                by teaching. <em>Frontiers in Psychology, 13</em>, 842668.
                <br />
                Karpicke, J. D., &amp; Blunt, J. R. (2011). Retrieval practice produces more
                learning than elaborative studying with concept mapping.{" "}
                <em>Science, 331</em>(6018), 772–775.
              </p>
            </div>

            <div className={styles.scienceBlock}>
              <h3 className={styles.h3}>3. Fluency through continuous practice</h3>
              <p>
                Research on spoken fluency consistently points to one driver: regular, low-stakes
                production practice. Fluency isn't a trait you have or don't have. It's a skill
                built through accumulated speaking time.
              </p>
              <p>
                A 2024 study on VR-enhanced language learning noted that fluency, the ability to
                speak smoothly and without unnecessary hesitation, "is often developed through
                continuous and meaningful practice." Structured environments that provide repeated
                opportunities for spontaneous speech were found to contribute directly to improved
                fluency.
              </p>
              <p>
                The structure of 60 Seconds creates the conditions for exactly this. A fresh topic
                each session, a fixed time constraint, a short preparation window. Every session
                is different enough to prevent mechanical rehearsal, and constrained enough to
                stay deliberate.
              </p>
              <p className={styles.ref}>
                Richards, J. C., &amp; Rodgers, T. S. (2014).{" "}
                <em>Approaches and Methods in Language Teaching</em> (3rd ed.). Cambridge
                University Press. As cited in: Developing English language learners' speaking
                skills through a situated learning approach in VR-enhanced experiences.{" "}
                <em>Virtual Reality</em> (2024).
              </p>
            </div>

            <div className={styles.scienceBlock}>
              <h3 className={styles.h3}>4. Preparation quality and speaking clarity</h3>
              <p>
                A study by Bögels et al. (2018) on temporal preparation for speaking found that
                when speakers are given time to prepare an answer, even briefly, the quality and
                fluency of their speech improves measurably. Preparation allows speakers to
                pre-plan their linguistic output, reducing mid-speech cognitive load and resulting
                in clearer, less disfluent delivery.
              </p>
              <p>
                The five-minute prep window in 60 Seconds isn't filler. It's the phase where
                you decide what you actually want to say: what the key point is, what the
                structure looks like, what you'll lead with. That cognitive work, done before
                you open your mouth, directly improves the clarity of what comes out.
              </p>
              <p className={styles.ref}>
                Bögels, S., Casillas, M., &amp; Levinson, S. C. (2018). Temporal preparation
                for speaking in question-answer sequences.{" "}
                <em>Frontiers in Psychology, 8</em>, 1880.
              </p>
            </div>

            <div className={styles.scienceBlock}>
              <h3 className={styles.h3}>5. Speaking rate and articulation</h3>
              <p>
                Research on speech clarity shows that speaking rate is one of the strongest
                predictors of perceived intelligibility and articulation quality. People who
                speak at a deliberate, controlled pace are consistently rated as clearer and
                easier to understand.
              </p>
              <p>
                The one-minute constraint does two things: it prevents the rambling that comes
                from having too much time, and it trains you to prioritise. To identify the most
                important points and lead with them. Over time, this shapes how you naturally
                organise speech under pressure.
              </p>
              <p className={styles.ref}>
                Stipancic, K. L., et al. (2023). Feedback from automatic speech recognition
                to elicit clear speech in healthy speakers.{" "}
                <em>American Journal of Speech-Language Pathology.</em>{" "}
                https://pmc.ncbi.nlm.nih.gov/articles/PMC10721250/
              </p>
            </div>
          </section>

          {/* The Loop */}
          <section className={styles.section}>
            <h2 className={styles.h2}>The Loop</h2>
            <div className={styles.loopDiagram}>
              <span>Pick an area</span>
              <span className={styles.arrow}>→</span>
              <span>Spin for a topic</span>
              <span className={styles.arrow}>→</span>
              <span>5 min prep</span>
              <span className={styles.arrow}>→</span>
              <span>60 seconds</span>
              <span className={styles.arrow}>→</span>
              <span>Done</span>
            </div>
            <p>
              Areas can be things you know well: a field you work in, a subject you studied.
              Or things you're learning: a new domain, a paper you read, a concept you keep
              meaning to understand properly.
            </p>
          </section>

          {/* What You Get */}
          <section className={styles.section}>
            <h2 className={styles.h2}>What You Get Over Time</h2>
            <ul className={styles.list}>
              <li>A habit of translating knowledge into clear speech</li>
              <li>Better instincts for what you actually understand versus what you only think you understand</li>
              <li>Less filler, less rambling, more structure</li>
              <li>A record of topics you've covered and areas you've explored</li>
            </ul>
          </section>

          {/* Who It's For */}
          <section className={styles.section}>
            <h2 className={styles.h2}>Who It's For</h2>
            <p>
              This started as a personal project. I kept noticing a gap between what I knew and
              what I could actually say out loud when it mattered. In a meeting, in a conversation,
              when someone asked me to explain something on the spot.
            </p>
            <p>
              If you know things but freeze when you have to explain them, if you ramble when you
              mean to be concise, if you want your thinking to sound as sharp as it feels inside
              your head — this is the tool I built for that.
            </p>
          </section>

          {/* References */}
          <section className={styles.section}>
            <h2 className={styles.h2}>References</h2>
            <ol className={styles.refList}>
              <li>
                Ericsson, K. A., Krampe, R. T., &amp; Tesch-Römer, C. (1993). The role of
                deliberate practice in the acquisition of expert performance.{" "}
                <em>Psychological Review, 100</em>(3), 363–406.
              </li>
              <li>
                Ericsson, K. A., &amp; Lehmann, A. C. (1996). Expert and exceptional
                performance: Evidence of maximal adaptation to task constraints.{" "}
                <em>Annual Review of Psychology, 47</em>, 273–305.
              </li>
              <li>
                Roediger, H. L., &amp; Karpicke, J. D. (2006). Test-enhanced learning: Taking
                memory tests improves long-term retention.{" "}
                <em>Psychological Science, 17</em>(3), 249–255.
              </li>
              <li>
                Karpicke, J. D., &amp; Blunt, J. R. (2011). Retrieval practice produces more
                learning than elaborative studying with concept mapping.{" "}
                <em>Science, 331</em>(6018), 772–775.
              </li>
              <li>
                Kobayashi, K. (2022). The retrieval practice hypothesis in research on learning
                by teaching: Current status and challenges.{" "}
                <em>Frontiers in Psychology, 13</em>, 842668.
              </li>
              <li>
                McDermott, K. B. (2021). Practicing retrieval facilitates learning.{" "}
                <em>Annual Review of Psychology, 72</em>, 609–633.
              </li>
              <li>
                Bögels, S., Casillas, M., &amp; Levinson, S. C. (2018). Temporal preparation
                for speaking in question-answer sequences.{" "}
                <em>Frontiers in Psychology, 8</em>, 1880.
              </li>
              <li>
                Richards, J. C., &amp; Rodgers, T. S. (2014).{" "}
                <em>Approaches and Methods in Language Teaching</em> (3rd ed.). Cambridge
                University Press.
              </li>
              <li>
                Tavakoli, P., &amp; Wright, C. (2020).{" "}
                <em>Second Language Speech Fluency: From Research to Practice.</em> Cambridge
                University Press.
              </li>
              <li>
                Stipancic, K. L., Borders, J. C., Thibeault, S. L., &amp; Hustad, K. C.
                (2023). Feedback from automatic speech recognition to elicit clear speech in
                healthy speakers. <em>American Journal of Speech-Language Pathology.</em>{" "}
                https://pmc.ncbi.nlm.nih.gov/articles/PMC10721250/
              </li>
            </ol>
          </section>

          {/* CTA */}
          <section className={styles.ctaSection}>
            <p className={styles.ctaText}>It takes six minutes a day.</p>
            <Link href="/signup" className={styles.ctaLink}>Start practicing →</Link>
          </section>

        </article>
      </main>
    </>
  );
}