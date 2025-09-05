"use client";
import { Swiper, SwiperSlide } from 'swiper/react'
import { Autoplay, EffectCoverflow } from 'swiper/modules'
import 'swiper/css'
import 'swiper/css/autoplay'
import 'swiper/css/navigation'
import 'swiper/css/pagination'
import 'swiper/css/effect-coverflow'
import { motion } from "motion/react";
import { HeroHighlight, Highlight } from "@/components/ui/hero-highlight";
import { InteractiveHoverButton } from '~~/components/magicui/interactive-hover-button';
import { GroupBeam } from './group-beam';
import { SingleBeam } from './personal-beam';
export function HeroHighlightDemo() {
  return (
    <div className='pt-12 mb-24'>
         <HeroHighlight>
      <motion.h1
        initial={{
          opacity: 0,
          y: 20,
        }}
        animate={{
          opacity: 1,
          y: [20, -5, 0],
        }}
        transition={{
          duration: 0.5,
          ease: [0.4, 0.0, 0.2, 1],
        }}
        className="text-2xl px-4 pt-36 md:text-4xl lg:text-5xl font-bold text-neutral-700 dark:text-white max-w-4xl leading-relaxed lg:leading-snug text-center mx-auto "
      >
        Save with Confidence. Lock your funds in smart contracts, not physical boxes. Join the future of{" "}
        <Highlight className="text-black dark:text-white">
          Decentralized Savings
        </Highlight>
      </motion.h1>
      <div className="reative mx-auto max-w-7xl px-6 md:px-12">
      <div className="mt-8 justify-center flex items-center mx-auto">
        <InteractiveHoverButton>
            Get Started
        </InteractiveHoverButton>
                        {/* <Button
                            size="lg"
                            asChild>
                            <Link href="#">
                                <Rocket className="relative size-4" />
                                <span className="text-nowrap">Start Building</span>
                            </Link>
                        </Button> */}
                    </div>
      <div className="x-auto relative mx-auto mt-8 max-w-lg sm:mt-12">
                    <div className="absolute inset-0 -top-8 left-1/2 -z-20 h-56 w-full -translate-x-1/2 [background-image:linear-gradient(to_bottom,transparent_98%,theme(colors.gray.200/75%)_98%),linear-gradient(to_right,transparent_94%,_theme(colors.gray.200/75%)_94%)] [background-size:16px_35px] [mask:radial-gradient(black,transparent_95%)] dark:opacity-10"></div>
                    <div className="absolute inset-x-0 top-12 -z-[1] mx-auto h-1/3 w-2/3 rounded-full bg-blue-300 blur-3xl dark:bg-white/20"></div>

                    <Swiper
                        slidesPerView={1}
                        pagination={{ clickable: true }}
                        loop
                        autoplay={{ delay: 5000 }}
                        modules={[Autoplay, EffectCoverflow]}>
                        <SwiperSlide className="px-2 max-w-[90vw] sm:max-w-full">
                        <p className="mt-6 text-center text-lg font-bold uppercase underline underline-offset-8">Group Contributions</p>
                            <GroupBeam />   
                        </SwiperSlide>
                        <SwiperSlide className="px-2 max-w-[90vw] sm:max-w-full">
                        <p className="mt-6 text-center text-lg font-bold uppercase underline underline-offset-8">Personal Contributions</p>
                            <SingleBeam />   
                        </SwiperSlide>
        
                    </Swiper>
                </div>
                </div>
    </HeroHighlight>
    </div>
   
  );
}


