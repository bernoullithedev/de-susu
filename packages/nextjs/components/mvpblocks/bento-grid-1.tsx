'use client';
import { cn } from '~~/lib/utils';
import { motion } from 'framer-motion';
import { ArrowRight, Shield, Users, Zap, Coins, Brain, Globe } from 'lucide-react';

interface BentoGridItemProps {
  title: string;
  description: string;
  icon: React.ReactNode;
  className?: string;
  size?: 'small' | 'medium' | 'large';
}

const BentoGridItem = ({
  title,
  description,
  icon,
  className,
  size = 'small',
}: BentoGridItemProps) => {
  const variants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { type: 'spring' as const, damping: 25 },
    },
  };

  return (
    <motion.div
      variants={variants}
      className={cn(
        'group border-primary/10 bg-background hover:border-primary/30 relative flex h-full cursor-pointer flex-col justify-between overflow-hidden rounded-xl border px-6 pt-6 pb-10 shadow-md transition-all duration-500',
        className,
      )}
    >
      <div className="absolute top-0 -right-1/2 z-0 size-full cursor-pointer bg-[linear-gradient(to_right,#3d16165e_1px,transparent_1px),linear-gradient(to_bottom,#3d16165e_1px,transparent_1px)] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_0%,#000_70%,transparent_100%)] bg-[size:24px_24px]"></div>

      <div className="text-primary/5 group-hover:text-primary/10 absolute right-1 bottom-3 scale-[6] transition-all duration-700 group-hover:scale-[6.2]">
        {icon}
      </div>

      <div className="relative z-10 flex h-full flex-col justify-between">
        <div>
          <div className="bg-primary/10 text-primary shadow-primary/10 group-hover:bg-primary/20 group-hover:shadow-primary/20 mb-4 flex h-12 w-12 items-center justify-center rounded-full shadow transition-all duration-500">
            {icon}
          </div>
          <h3 className="mb-2 text-xl font-semibold tracking-tight">{title}</h3>
          <p className="text-muted-foreground text-sm">{description}</p>
        </div>
        <div className="text-primary mt-4 flex items-center text-sm">
          <span className="mr-1">Learn more</span>
          <ArrowRight className="size-4 transition-all duration-500 group-hover:translate-x-2" />
        </div>
      </div>
      <div className="from-primary to-primary/30 absolute bottom-0 left-0 h-1 w-full bg-gradient-to-r blur-2xl transition-all duration-500 group-hover:blur-lg" />
    </motion.div>
  );
};

const items = [
  {
    title: 'Decentralized Security',
    description:
      'Your savings are locked in immutable smart contracts. No intermediaries, no theft, no fraud - just pure blockchain security.',
    icon: <Shield className="size-6" />,
    size: 'large' as const,
  },
  {
    title: 'Ultra-Low Fees',
    description:
      'Built on Base network for lightning-fast, ultra-cheap transactions. Save more with minimal costs.',
    icon: <Coins className="size-6" />,
    size: 'small' as const,
  },
  {
    title: 'Group Savings Vaults',
    description:
      'Save together with friends and family. Create shared vaults with automated contributions and fair payouts.',
    icon: <Users className="size-6" />,
    size: 'medium' as const,
  },
  {
    title: 'Automated Streaming',
    description:
      'Set up automatic, recurring deposits. Build savings discipline with seamless, gasless micro-transactions.',
    icon: <Zap className="size-6" />,
    size: 'medium' as const,
  },
 
  {
    title: 'AI-Powered Insights',
    description:
      'Get personalized savings predictions and tips powered by AI. Make smarter financial decisions.',
    icon: <Brain className="size-6" />,
    size: 'small' as const,
  },
  {
    title: 'Global Accessibility',
    description:
      'Use human-readable ENS names for easy sharing. Send and receive across borders with seamless integration.',
    icon: <Globe className="size-6" />,
    size: 'large' as const,
  },
];

export  function BentoGrid1() {
  const containerVariants = {
    hidden: {},
    visible: {
      transition: {
        staggerChildren: 0.12,
        delayChildren: 0.1,
      },
    },
  };

  return (
    <div className="mx-auto max-w-6xl px-4 py-12 pt-16">
      <h1 className='text-center uppercase text-4xl font-extrabold'>About / Features</h1>
      <motion.div
        className="grid grid-cols-1 gap-4 sm:grid-cols-2 md:grid-cols-6"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        {items.map((item, i) => (
          <BentoGridItem
            key={i}
            title={item.title}
            description={item.description}
            icon={item.icon}
            size={item.size}
            className={cn(
              item.size === 'large'
                ? 'col-span-4'
                : item.size === 'medium'
                  ? 'col-span-3'
                  : 'col-span-2',
              'h-full',
            )}
          />
        ))}
      </motion.div>
    </div>
  );
}
