'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { cn } from '@/lib/utils';
import { Badge } from '@/components/ui/badge';
import { MinusIcon, PlusIcon } from 'lucide-react';

interface FaqItem {
  id: string;
  question: string;
  answer: string;
  category: 'general' | 'technical' | 'support';
}

const faqItems: FaqItem[] = [
  {
    id: '1',
    question: 'What is a Susu Vault?',
    answer:
      'A Susu Vault is a modern, blockchain-based version of the traditional Ghanaian "susu" savings system. Instead of using physical boxes or trusting a collector, you can securely lock your money in a smart contract for a set period. This eliminates the risk of theft, fraud, or loss while ensuring your savings grow safely over time.',
    category: 'general',
  },
  {
    id: '2',
    question: 'How is this different from traditional susu?',
    answer:
      'Traditional susu relies on physical boxes or trusted collectors who might disappear with your money. Our decentralized Susu Vault uses blockchain technology - your funds are locked in immutable smart contracts on the Base network. No third party can access your money, and everything is transparent and automated.',
    category: 'general',
  },
  {
    id: '3',
    question: 'Is my money safe in the Susu Vault?',
    answer:
      'Yes, your money is very safe! It\'s locked in smart contracts on the blockchain, which means no one - not even us - can access it before your chosen unlock time. The contracts are transparent, auditable, and use proven blockchain security. You maintain full control of your funds at all times.',
    category: 'general',
  },
  {
    id: '4',
    question: 'Can I withdraw my money anytime?',
    answer:
      'No, that\'s the whole point of susu savings! You set a lock period when you create your vault (days, weeks, or months), and your money remains locked until that time expires. This prevents impulsive spending and helps you build the discipline needed for successful saving.',
    category: 'general',
  },
  {
    id: '5',
    question: 'How do group susu vaults work?',
    answer:
      'Group susu allows you and your friends/family to save together. You create a shared vault with rules (contribution amounts, lock periods, payout rotations). Everyone contributes regularly, and payouts are distributed automatically according to your group rules. It\'s perfect for community savings or family goals.',
    category: 'general',
  },
  {
    id: '6',
    question: 'What happens if someone doesn\'t contribute to our group?',
    answer:
      'The smart contract enforces the rules automatically. If a member misses their contribution, they won\'t be eligible for the next payout rotation. The contract is transparent - everyone can see all contributions and progress. This ensures fairness and accountability within your group.',
    category: 'general',
  },
  {
    id: '7',
    question: 'What blockchain is Susu Vault built on?',
    answer:
      'Susu Vault is built on the Base network, an Ethereum Layer 2 solution. This provides fast, low-cost transactions while maintaining the security of Ethereum. Base is perfect for micro-transactions and savings applications like ours.',
    category: 'technical',
  },
  {
    id: '8',
    question: 'What integrations does Susu Vault use?',
    answer:
      'We integrate several powerful tools: ENS for human-readable names (e.g., "kwame.eth"), Superfluid for automatic streaming deposits, Chainlink for secure timekeeping and price feeds, and JigsawStack for AI-powered savings insights. These integrations make saving easier and more accessible.',
    category: 'technical',
  },
  {
    id: '9',
    question: 'Are the smart contracts audited?',
    answer:
      'Our smart contracts follow best practices and use well-tested patterns from the Ethereum ecosystem. For production use, we recommend having them audited by a professional security firm. The contracts are built using Foundry and are designed to be simple, secure, and transparent.',
    category: 'technical',
  },
  {
    id: '10',
    question: 'How does Superfluid streaming work?',
    answer:
      'Superfluid allows you to set up automatic, recurring deposits to your vault. Instead of depositing a lump sum, you can stream small amounts continuously over time (like salary deductions). This makes saving effortless and helps build consistent financial habits.',
    category: 'technical',
  },
  {
    id: '11',
    question: 'What are the fees for using Susu Vault?',
    answer:
      'We keep fees extremely low thanks to Base\'s efficient Layer 2 network. You only pay minimal gas fees for blockchain transactions - there are no platform fees or hidden charges. This makes susu accessible to everyone, regardless of income level.',
    category: 'technical',
  },
  {
    id: '12',
    question: 'How can I get help if I have questions?',
    answer:
      'You can reach out through our GitHub repository for technical issues, or join the ETHAccra Discord community. We also have AI-powered support through JigsawStack that can help answer common questions. For group-related issues, check our transparent on-chain tracking first.',
    category: 'support',
  },
];

const categories = [
  { id: 'general', label: 'General' },
  { id: 'technical', label: 'Technical' },
  { id: 'support', label: 'Support' },
];

export default function Faq2() {
  const [activeCategory, setActiveCategory] = useState<string>('general');
  const [expandedId, setExpandedId] = useState<string | null>(null);

  const filteredFaqs = faqItems.filter((item) => item.category === activeCategory);

  const toggleExpand = (id: string) => {
    setExpandedId(expandedId === id ? null : id);
  };

  return (
    <section className="bg-background py-12">
      <div className="container mx-auto max-w-5xl px-4 md:px-6">
        <div className="mb-8 flex flex-col items-center">
          <Badge
            variant="outline"
            className="border-primary mb-3 px-3 py-1 text-xs font-medium tracking-wider uppercase"
          >
            FAQs
          </Badge>

          <h2 className="text-foreground mb-4 text-center text-3xl font-bold tracking-tight md:text-4xl">
            Frequently Asked Questions
          </h2>

          <p className="text-muted-foreground max-w-xl text-center text-sm">
            Find answers to common questions about Susu Vault and how we implemented it.
          </p>
        </div>

        {/* Category Tabs */}
        <motion.div
          className="mb-6 flex flex-wrap justify-center gap-1"
          layout
        >
          {categories.map((category) => (
            <motion.button
              key={category.id}
              layout
              onClick={() => setActiveCategory(category.id)}
              className={cn(
                'relative rounded-lg px-4 py-2 text-sm font-medium transition-all duration-200',
                activeCategory === category.id
                  ? 'bg-primary text-primary-foreground shadow-md'
                  : 'text-muted-foreground hover:text-foreground hover:bg-card/20',
              )}
              whileHover={{
                scale: 1.05,
                transition: { duration: 0.15 }
              }}
              whileTap={{
                scale: 0.95,
                transition: { duration: 0.1 }
              }}
              animate={{
                backgroundColor: activeCategory === category.id
                  ? 'hsl(var(--primary))'
                  : 'transparent'
              }}
            >
              {activeCategory === category.id && (
                <motion.div
                  className="absolute inset-0 rounded-lg bg-primary"
                  layoutId="activeTab"
                  transition={{
                    type: "spring",
                    bounce: 0.2,
                    duration: 0.6
                  }}
                />
              )}
              <span className="relative z-10">{category.label}</span>
            </motion.button>
          ))}
        </motion.div>

        {/* FAQ Grid */}
        <motion.div
          className="grid grid-cols-1 gap-4 md:grid-cols-2"
          layout
        >
          <AnimatePresence mode="popLayout" custom={activeCategory}>
            {filteredFaqs.map((faq, index) => (
              <motion.div
                key={`${activeCategory}-${faq.id}`}
                layout
                layoutId={`${activeCategory}-${faq.id}`}
                initial={{
                  opacity: 0,
                  y: 30,
                  scale: 0.95
                }}
                animate={{
                  opacity: 1,
                  y: 0,
                  scale: 1
                }}
                exit={{
                  opacity: 0,
                  y: -20,
                  scale: 0.95,
                  transition: { duration: 0.2 }
                }}
                transition={{
                  duration: 0.4,
                  delay: index * 0.08,
                  ease: [0.25, 0.46, 0.45, 0.94], // Custom easing for smooth animation
                  layout: { duration: 0.3 }
                }}
                className={cn(
                  'h-fit overflow-hidden rounded-lg',
                  expandedId === faq.id ? 'bg-card/30' : 'hover:bg-card/20',
                )}
                style={{ minHeight: '72px' }}
              >
                <motion.button
                  onClick={() => toggleExpand(faq.id)}
                  className="flex w-full items-center justify-between p-4 text-left"
                  whileTap={{ scale: 0.98 }}
                  transition={{ duration: 0.1 }}
                >
                  <motion.h3
                    className="text-foreground text-base font-medium pr-4"
                    animate={{
                      color: expandedId === faq.id
                        ? 'hsl(var(--primary))'
                        : 'hsl(var(--foreground))'
                    }}
                    transition={{ duration: 0.2 }}
                  >
                    {faq.question}
                  </motion.h3>
                  <motion.div
                    className="flex-shrink-0"
                    animate={{
                      rotate: expandedId === faq.id ? 180 : 0,
                      scale: expandedId === faq.id ? 1.1 : 1
                    }}
                    transition={{
                      duration: 0.3,
                      ease: [0.25, 0.46, 0.45, 0.94]
                    }}
                  >
                    {expandedId === faq.id ? (
                      <MinusIcon className="text-primary h-4 w-4" />
                    ) : (
                      <PlusIcon className="text-primary h-4 w-4" />
                    )}
                  </motion.div>
                </motion.button>

                <AnimatePresence>
                  {expandedId === faq.id && (
                    <motion.div
                      initial={{
                        height: 0,
                        opacity: 0,
                        y: -10,
                        scaleY: 0.8
                      }}
                      animate={{
                        height: 'auto',
                        opacity: 1,
                        y: 0,
                        scaleY: 1
                      }}
                      exit={{
                        height: 0,
                        opacity: 0,
                        y: -10,
                        scaleY: 0.8,
                        transition: { duration: 0.25 }
                      }}
                      transition={{
                        duration: 0.4,
                        ease: [0.25, 0.46, 0.45, 0.94],
                        opacity: { duration: 0.3 }
                      }}
                      className="overflow-hidden"
                    >
                      <motion.div
                        className="px-4 pb-4 pt-2"
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        transition={{ delay: 0.1, duration: 0.3 }}
                      >
                        <p className="text-muted-foreground text-sm leading-relaxed">{faq.answer}</p>
                      </motion.div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>
            ))}
          </AnimatePresence>
        </motion.div>

        {/* Contact CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3, duration: 0.3 }}
          className="mt-8 text-center"
        >
          <p className="text-muted-foreground mb-3 text-sm">
            Can&apos;t find what you&apos;re looking for?
          </p>
          <a
            href="#"
            className="text-primary hover:text-primary/80 inline-flex items-center justify-center px-4 py-2 font-medium transition-colors"
          >
            Contact Support
          </a>
        </motion.div>
      </div>
    </section>
  );
}
