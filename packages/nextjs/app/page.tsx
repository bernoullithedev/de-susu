import {NavbarDemo as Navbar} from "~~/components/landing/ace-navbar"
import Faq2 from "~~/components/landing/faqs"
import { HeroHighlightDemo as Hero } from "~~/components/landing/hero/hero"
import {BentoGrid1 as Features} from "~~/components/mvpblocks/bento-grid-1"

function Home() {
  return (
    <main>
    <Navbar />
    <Hero />
    <Features />
    <Faq2 />
    </main>
  )
}

export default Home