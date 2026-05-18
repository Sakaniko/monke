import { type FeatureChoiced, FeatureDropdownInput } from '../base';

/* Limb Choice */
export const prosthetic: FeatureChoiced = {
  name: 'Prosthetic',
  component: FeatureDropdownInput,
};

export const monoplegic: FeatureChoiced = {
  name: 'Amputated Limb',
  component: FeatureDropdownInput,
};

export const amputee: FeatureChoiced = {
  name: 'Missing Limb',
  component: FeatureDropdownInput,
}

/* Hemiplegic Side */
export const hemiplegic_side: FeatureChoiced = {
  name: 'Paralysed Side',
  component: FeatureDropdownInput,
};
