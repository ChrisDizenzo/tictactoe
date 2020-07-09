import React from 'react';
import clsx from 'clsx';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import useBaseUrl from '@docusaurus/useBaseUrl';
import styles from './styles.module.css';

const features = [
  {
    title: <>Anytime, Anywhere, with Anyone</>,
    imageUrl: 'img/share.svg',
    description: (
      <>
        Tic Tac Toe was made with a TCP live server with a NodeJS backend in the socket.io framework, letting you play live with your friends and chat in real time.
      </>
    ),
  },
  {
    title: <>Powered by Swift</>,
    imageUrl: 'img/server.svg',
    description: (
      <>
        Using the latest stable release of Swift 5.2.4, the Tic Tac Toe app delivers high fidelity feedback and a world-class user experience.
      </>
    ),
  },
  {
    title: <>Secure, like Tic Tac Toe should be</>,
    imageUrl: 'img/cloud-server.svg',
    description: (
      <>
        Since all gameplay is accounted for on the server side, you can be sure that all interactions are immediate and quality-controlled to prevent hackers and cheaters.
      </>
    ),
  },
];

function Feature({imageUrl, title, description}) {
  const imgUrl = useBaseUrl(imageUrl);
  return (
    <div className={clsx('col col--4', styles.feature)}>
      {imgUrl && (
        <div className="text--center">
          <img className={styles.featureImage} src={imgUrl} alt={title} />
        </div>
      )}
      <h3>{title}</h3>
      <p>{description}</p>
    </div>
  );
}

function Home() {
  const context = useDocusaurusContext();
  const {siteConfig = {}} = context;
  return (
    <Layout
      title={`Hello from ${siteConfig.title}`}
      description="Description will go into a meta tag in <head />">
      <header className={clsx('hero hero--primary', styles.heroBanner)}>
        <div className="container">
          <h1 className="hero__title">{siteConfig.title}</h1>
          <p className="hero__subtitle">{siteConfig.tagline}</p>
          <div className={styles.buttons}>
            <Link
              className={clsx(
                'button button--outline button--secondary button--lg',
                styles.getStarted,
              )}
              to={useBaseUrl('docs/')}>
              Get Started
            </Link>
          </div>
        </div>
      </header>
      <main>
        {features && features.length > 0 && (
          <section className={styles.features}>
            <div className="container">
              <div className="row">
                {features.map((props, idx) => (
                  <Feature key={idx} {...props} />
                ))}
              </div>
            </div>
          </section>
        )}
      </main>
    </Layout>
  );
}

export default Home;
